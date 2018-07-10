## Splay Controller ### v1.0.7 ###
## Copyright 2006-2011
## http://www.splay-project.org
## 
## 
## 
## This file is part of Splay.
## 
## Splayd is free software: you can redistribute it and/or modify 
## it under the terms of the GNU General Public License as published 
## by the Free Software Foundation, either version 3 of the License, 
## or (at your option) any later version.
## 
## Splayd is distributed in the hope that it will be useful,but 
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
## See the GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Splayd. If not, see <http://www.gnu.org/licenses/>.


# NOTE
# When we try to select splayds for a job, the only case that could require a
# synchro is that a splayd can have more new free slots than what we have check
# (because a slot can be freed during the select phase). But that is never a
# problem ! So no locks are needed.

class JobdStandard < Jobd

	@@scheduler = 'standard'

	# LOCAL => REGISTERING|NO RESSOURCES
	def self.status_local

		@@dlock_jr.get
		c_splayd = nil

		$db["SELECT * FROM jobs WHERE scheduler='#{@@scheduler}' AND status='LOCAL'"].each do |job|

			# Cache at the first call
			unless c_splayd
				c_splayd = {}
				c_splayd['nb_nodes'] = {}
				c_splayd['max_number'] = {}

				# Do not take only AVAILABLE splayds here because new ones can become
				# AVAILABLE before the next filters.
				$db["SELECT id, max_number FROM splayds"].each do |m|
					c_splayd['max_number'][m[:id]] = m[:max_number]
					c_splayd['nb_nodes'][m[:id]] = 0
				end

				$db["SELECT splayd_id, COUNT(job_id) as nb_nodes
						FROM splayd_jobs
						GROUP BY splayd_id"].each do |ms|
					c_splayd['nb_nodes'][ms[:splayd_id]] = ms[:nb_nodes]
				end
			end

			status_msg = ""

			normal_ok = true

			# To select the splayds that have the lowest percentage of occupation 
			occupation = {}

			$db[create_filter_query(job)].each do |m|

				if m[:network_send_speed] / c_splayd['max_number'][m[:id]] >=
						job[:network_send_speed] and
						m[:network_receive_speed] / c_splayd['max_number'][m[:id]] >=
						job[:network_receive_speed]

					if c_splayd['nb_nodes'][m[:id]] < c_splayd['max_number'][m[:id]]
						occupation[m[:id]] =
								c_splayd['nb_nodes'][m[:id]] / c_splayd['max_number'][m[:id]].to_f
					end
				end
			end

			if occupation.size < job[:nb_splayds]
				status_msg += "Not enough splayds found with the requested ressources " +
						"(only #{occupation.size} instead of #{job[:nb_splayds]})"
				normal_ok = false
			end

			### Mandatory splayds
			mandatory_ok = true

			$db["SELECT * FROM job_mandatory_splayds
					WHERE job_id='#{job[:id]}'"].each do |mm|

				m = $db["SELECT id, ref FROM splayds WHERE
						id='#{mm[:splayd_id]}'
						#{ressources_filter}
						#{bytecode_filter}"].first

				if m
					if c_splayd['nb_nodes'][m[:id]] == c_splayd['max_number'][m[:id]]
						status_msg += "Mandatory splayd: #{m['ref']} " +
								"has no free slot.\n"
						mandatory_ok = false
					end
					# No bandwith test for mandatory (other than the ressources
					# filter).
				else
					status_msg += "Mandatory splayd: #{m['ref']} " +
							" has not the requested ressources or is not avaible.\n"
					mandatory_ok = false
				end
			end

			if not mandatory_ok or not normal_ok
				set_job_status(job[:id], 'NO_RESSOURCES', status_msg)
				next
			end

			# We will send the job !

			new_job = create_job_json(job)

			# We choose more splayds (if possible) than needed, to keep the best ones
			factor = job[:factor].to_f
			nb_selected_splayds = (job[:nb_splayds] * factor).ceil



			q_sel = ""
			q_job = ""
			q_act = ""

			count = 0
			occupation.sort {|a, b| a[1] <=> b[1]}
			occupation.each do |splayd_id, occ|
				q_sel = q_sel + "('#{splayd_id}','#{job[:id]}'),"
				q_job = q_job + "('#{splayd_id}','#{job[:id]}','RESERVED'),"
				q_act = q_act + "('#{splayd_id}','#{job[:id]}','REGISTER', 'TEMP'),"
	
				# We update the cache
				c_splayd['nb_nodes'][splayd_id] = c_splayd['nb_nodes'][splayd_id] + 1

				count += 1
				if count >= nb_selected_splayds then break end
			end

			$db["SELECT * FROM job_mandatory_splayds
					WHERE job_id='#{job[:id]}'"].each do |mm|

				splay_id = mm[:splayd_id]
				q_sel = q_sel + "('#{splayd_id}','#{job[:id]}'),"
				q_job = q_job + "('#{splayd_id}','#{job[:id]}','RESERVED'),"
				q_act = q_act + "('#{splayd_id}','#{job[:id]}','REGISTER', 'TEMP'),"

				# We update the cache
				c_splayd['nb_nodes'][splayd_id] = c_splayd['nb_nodes'][splayd_id] + 1
			end
			q_sel = q_sel[0, q_sel.length - 1]
			q_job = q_job[0, q_job.length - 1]
			q_act = q_act[0, q_act.length - 1]
			$db.run("INSERT INTO splayd_selections (splayd_id, job_id) VALUES #{q_sel}")
			$db.run("INSERT INTO splayd_jobs (splayd_id, job_id, status) VALUES #{q_job}")

			$db.run("INSERT INTO actions (splayd_id, job_id, command, status) VALUES #{q_act}")
			$db.run("UPDATE actions SET data='#{addslashes(new_job)}', status='WAITING'
					WHERE job_id='#{job[:id]}' AND command='REGISTER' AND status='TEMP'")


			set_job_status(job[:id], 'REGISTERING')
		end
		@@dlock_jr.release
	end

	# REGISTERING => REGISTERING_TIMEOUT|RUNNING
	def self.status_registering
		$db["SELECT * FROM jobs WHERE
				scheduler='#{@@scheduler}' AND status='REGISTERING'"].each do |job|

			# Mandatory filter
			mandatory_filter = ''
			$db["SELECT * FROM job_mandatory_splayds
					WHERE job_id='#{job[:id]}'"].each do |mm|
				mandatory_filter += " AND splayd_id!=#{mm[:splayd_id]} "
			end

			# NOTE ORDER BY reply_time can not be an excellent idea in that sense that
			# it could advantage splayd near of the controller.
			selected_splayds = []
			$db["SELECT splayd_id FROM splayd_selections WHERE
					job_id='#{job[:id]}' AND
					replied='TRUE'
					#{mandatory_filter}
					ORDER BY reply_time LIMIT #{job[:nb_splayds]}"].each do |m|
				selected_splayds << m[:splayd_id]
			end

			# check if enough splayds have responded
			normal_ok = selected_splayds.size == job[:nb_splayds]

			mandatory_ok = true

			$db["SELECT * FROM job_mandatory_splayds
					WHERE job_id='#{job[:id]}'"].each do |mm|
				unless $db["SELECT id FROM splayd_selections WHERE
						splayd_id='#{mm[:splayd_id]}' AND
						job_id='#{job[:id]}' AND
						replied='TRUE'"].first
					mandatory_ok = false
					break
				end
			end
			
			if normal_ok and mandatory_ok

				selected_splayds.each do |splayd_id|
					$db.run("UPDATE splayd_selections SET
							selected='TRUE'
							WHERE
							splayd_id='#{splayd_id}' AND
							job_id='#{job[:id]}'")
				end
				$db["SELECT * FROM job_mandatory_splayds
						WHERE job_id='#{job[:id]}'"].each do |mm|

					$db.run("UPDATE splayd_selections SET
							selected='TRUE'
							WHERE
							splayd_id='#{mm[:splayd_id]}' AND
							job_id='#{job[:id]}'")
				end

				# We need to unregister the job on the non selected splayds.
				q_act = ""
				$db["SELECT * FROM splayd_selections WHERE
						job_id='#{job[:id]}' AND
						selected='FALSE'"].each do |m_s|
					q_act = q_act + "('#{m_s[:splayd_id]}','#{job[:id]}','FREE', '#{job[:ref]}'),"
				end
				if q_act != ""
					q_act = q_act[0, q_act.length - 1]
					$db.run("INSERT INTO actions (splayd_id, job_id, command, data) VALUES #{q_act}")
				end



				send_all_list(job, "SELECT * FROM splayd_selections WHERE
						job_id='#{job[:id]}' AND selected='TRUE'")

				# We change it before sending the START commands because it
				# seems more consistant... We had problem with first jobs
				# begining to log before the status change was done and refused
				# by the log server.
				set_job_status(job[:id], 'RUNNING')

				# Create a symlink to the log dir
				File.symlink("#{@@log_dir}/#{job[:id]}", "#{@@link_log_dir}/#{job[:ref]}.txt")

				send_start(job, "SELECT * FROM splayd_selections WHERE job_id='#{job[:id]}' AND selected='TRUE'")
				

			else
				if Time.now.to_i > job[:status_time] + @@register_timeout
					# TIMEOUT !

					$db.run("DELETE FROM actions WHERE
							job_id='#{job[:id]}' AND
							command='REGISTER'")

					# send unregister action
					# We need to unregister the job on all the splayds.
					$db["SELECT * FROM splayd_selections WHERE
							job_id='#{job[:id]}'"].each do |m_s|
						# TODO optimization
						Splayd::add_action m_s[:splayd_id], job[:id], 'FREE', job[:ref]
					end

					$db.run("DELETE FROM splayd_selections WHERE
							job_id='#{job[:id]}'")
					set_job_status(job[:id], 'REGISTER_TIMEOUT')
				end
			end
		end
	end

	# RUNNING => ENDED
	def self.status_running
		$db["SELECT * FROM jobs WHERE
				scheduler='#{@@scheduler}' AND status='RUNNING'"].each do |job|
			unless $db["SELECT * FROM splayd_jobs
				WHERE job_id='#{job[:id]}' AND status!='RESERVED'"].first
				set_job_status(job[:id], 'ENDED')
			end
		end
	end
			
	def self.kill_job(job, status_msg = '')
		$log.info("KILLING #{job[:id]}")
		case job[:status]
		# NOTE do nothing for jobs in these states:
		#when 'KILLED':
		#when 'ENDED':
		#when 'NO_RESSOURCES':
		#when 'REGISTER_TIMEOUT':
		when 'LOCAL'
			set_job_status(job[:id], 'KILLED')
		when 'REGISTERING', 'RUNNING'
			q_act = ""
			$db["SELECT * FROM splayd_jobs WHERE
					job_id='#{job[:id]}'"].each do |m_s|
				# STOP doesn't remove the job from the splayd
				q_act = q_act + "('#{m_s[:splayd_id]}','#{job[:id]}','FREE', '#{job[:ref]}'),"
			end
			if q_act != ""
				q_act = q_act[0, q_act.length - 1]
				$db.run("INSERT INTO actions (splayd_id, job_id, command, data) VALUES #{q_act}")
			end
			set_job_status(job[:id], 'KILLED', status_msg)
		end
	end

	def self.command
		# NOTE splayd_jobs table is cleaned directly by splayd when it apply the
		# free command (or reset)
		$db["SELECT * FROM jobs WHERE scheduler='#{@@scheduler}' AND
				command IS NOT NULL"].each do |job|
			if job[:command] =~ /kill|KILL/
				kill_job(job, "user kill")
			else
				msg = "Not understood command: #{job[:command]}"
				$db.run("UPDATE jobs SET command_msg='#{msg}' WHERE id='#{job[:id]}'")
			end
			$db.run("UPDATE jobs SET command='' WHERE id='#{job[:id]}'")
		end
	end

	# KILL AT
	def self.kill_max_time
		$db["SELECT * FROM jobs WHERE
				scheduler='#{@@scheduler}' AND
				status='RUNNING' AND
				max_time IS NOT NULL AND
				status_time + max_time < #{Time.now.to_i}"].each do |job|
			kill_job(job, "max execution time")
		end
	end

end
