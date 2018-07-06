## Splay Controller ### v1.1 ###
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

# JSON-RPC over HTTP client for SPLAY controller in Ruby - server side
# Created by José Valerio
#
# based on tutorial for Orbjson:
# http://orbjson.rubyforge.org/tutorial/getting_started_with_orbjson_short_version.pdf
# http://orbjson.rubyforge.org/tutorial/tutorial_code.tgz

require '../lib/common.rb'
#library required for hashing
require 'digest/sha1'
#Main class
class Ctrl_api
	#function get_log: triggered when a "GET LOG" message is received, returns the corresponding log file as a string
	def get_log(job_id, session_id)
		#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID
		# is valid)
		if user
      #user_id is taken from the field 'id' from variable user
			user_id = user['id']
			#if the user is admin (can see all the jobs) or the job belongs to her
			if (user['admin'] == 1) or ($db["SELECT * FROM jobs WHERE id=#{job_id} AND user_id=#{user_id}"].first)
        #opens the log file of the requested job
				log_file = File.open("../logs/"+job_id) 
				#ok is true
				ret['ok'] = true
				#log is a string containing the log file
				ret['log'] = log_file.read
				#closes the file
				log_file.close
				#returns ret
				return ret
			end
			#if the 'if (user)' statement was true, the function would have ended with the return on the line above,
			# if not, the following lines are processed
			#ok is false
			ret['ok'] = false
			#error says that the job doesn't exist
			ret['error'] = "Job does not exist for this user"
			#returns ret
			return ret
		end
		#if session ID was not valid, ok is false
		ret['ok'] = false
		#error says that the session ID was invalid
		ret['error'] = "Invalid or expired Session ID"
		#returns ret
    ret
	end

#function get_job_code: triggered when a "GET JOB CODE" message is received, returns the corresponding
# source code as a string
	def get_job_code(job_id, session_id)
		#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID is valid)
		if user
      #user_id is taken from the field 'id' from variable user
			user_id = user['id']
			#job is the record that matches the job_id
			job = $db["SELECT * FROM jobs WHERE id=#{job_id}"].first
			#if job exists
			if job
        #if the user is admin (can see all the jobs) or the job belongs to her
				if (user['admin'] == 1) or (job[:user_id] == user_id)
          #ok is true
					ret['ok'] = true
					#code is a string containing the code
					ret['code'] = job[:code]
					#returns ret
					return ret
				end
			end
			#if the 'if (user)' statement was true, the function would have ended with the return on the line above,
			# if not, the following lines are processed
			#ok is false
			ret['ok'] = false
			#error says that the job doesn't exist
			ret['error'] = "Job does not exist for this user"
			#returns ret
			return ret
		end
		#if session ID was not valid, ok is false
		ret['ok'] = false
		#error says that the session ID was invalid
		ret['error'] = "Invalid or expired Session ID"
		#returns ret
    ret
	end

	#function kill_job: triggered when a "KILL JOB" message is received, sends a KILL command to a job
	def kill_job(job_id, session_id)
		#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID is valid)
		if user
      #user_id is taken from the field 'id' from variable user
			user_id = user['id']
			#if the user is admin (can see all the jobs) or the job belongs to her
			if (user['admin'] == 1) or ($db["SELECT * FROM jobs WHERE id=#{job_id} AND user_id=#{user_id}"].first)
        #writes KILL in the field 'command' of table 'jobs'; the contoller takes this command as an order
				# to kill the job
				$db.run("UPDATE jobs SET command='KILL' WHERE id='#{job_id}'")
				#ok is true
				ret['ok'] = true
				#returns ret
				return ret
			end
			#if the user is not admin and the job doesn't belong to her, ok is false
			ret['ok'] = false
			#error says that the job doesn't exist for the given user (if user is admin, the job doesn't exist at all)
			ret['error'] = "Job does not exist for this user"
		end
		#if the session was not valid, ok is false
		ret['ok'] = false
		#error says that the session was not valid
		ret['error'] = "Invalid or expired Session ID"
		#returns ret
    ret
	end

	#function submit_job: triggered when a "SUBMIT JOB" message is received, submits a job to the controller
	def submit_job(name, description, code, nb_splayds, churn_trace, options, session_id, scheduled_at, strict)
	 	#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID is valid)
		if user
      ref = OpenSSL::Digest::MD5.hexdigest(rand(1000000).to_s)
			#user_id is taken from the field 'id' from variable user
			user_id = user['id']
			
			time_now = Time.new.strftime("%Y-%m-%d %T")
			
			if options.class == Array
        options = Hash.new
			end
			if nb_splayds
        if nb_splayds > 0
          options['nb_splayds'] = nb_splayds
				end
			end
			
			if description == ""
        description_field = ""
			else
				description_field = "description='#{description}',"
			end
			
			if name == ""
        name_field = ""
			else
				name_field = "name='#{name}',"
			end

      # scheduled job
      if scheduled_at && (scheduled_at > 0)
        time_scheduled = Time.at(scheduled_at).strftime("%Y-%m-%d %T")
				options['scheduled_at'] = time_scheduled
      end

			# strict job
      if strict == "TRUE"
        options['strict'] = strict
      end
			
			if churn_trace == ""
        churn_field = ""
			else
				options['nb_splayds'] = 0
				churn_trace.lines do |line|
					options['nb_splayds'] = options['nb_splayds'] + 1
				end
				options['scheduler'] = 'trace'
				churn_field = "die_free='FALSE', scheduler_description='#{addslashes(churn_trace)}',"
			end

			$db.run("INSERT INTO jobs SET ref='#{ref}' #{to_sql(options)}, #{description_field} #{name_field} #{churn_field} code='#{addslashes(code)}', user_id=#{user_id}, created_at='#{time_now}'")

			timeout = 30
			while timeout > 0
				sleep(1)
				timeout = timeout - 1
				job = $db["SELECT * FROM jobs WHERE ref='#{ref}'"].first
				if job[:status] == "RUNNING"
          ret['ok'] = true
					ret['job_id'] = job[:id]
					ret['ref'] = ref
					return ret
				end
				if job[:status] == "NO_RESSOURCES"
          ret['ok'] = false
					ret['error'] = "JOB " + job[:id].to_s + ": " + job[:status_msg]
					return ret
				end
                                # queued job behavior
				if job[:status] == "QUEUED"
          ret['ok'] = true
					ret['job_id'] = job[:id]
					ret['ref'] = ref
					return ret
				end
			end
			#if timeout reached 0, ok is false
			ret['ok'] = false
			#error says that a timeout occured and suggests to check if the controller is running
			ret['error'] = "JOB " + job[:id].to_s + ": timeout; please check if controller is running"
			#returns ret
			return ret
		end
		ret['ok'] = false
		ret['error'] = "Invalid or expired Session ID"
    ret
	end

	#function get_job_details: triggered when a "GET JOB DETAILS" message is received, returns the description, status and
	#host list of the job
	def get_job_details(job_id, session_id)
		#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID is valid)
		if user
      #user_id is taken from the field 'id' from variable user
			user_id = user['id']
			#if the user is admin (can see all the jobs) or the job belongs to her
			if (user['admin'] == 1) or ($db["SELECT * FROM jobs WHERE id=#{job_id} AND user_id=#{user_id}"].first)
        host_list = Array.new
				$db["SELECT * FROM splayd_selections WHERE job_id='#{job_id}' AND selected='TRUE'"].each do |ms|
					m = $db["SELECT * FROM splayds WHERE id='#{ms['splayd_id']}'"].first
					host = Hash.new
					host['splayd_id'] = ms[:splayd_id]
					host['ip'] = m[:ip]
					host['port'] = ms[:port]
					host_list.push(host)
				end
				job = $db["SELECT * FROM jobs WHERE id=#{job_id}"].first
				ret['ok'] = true
				ret['host_list'] = host_list
				ret['status'] = job[:status]
				ret['ref'] = job[:ref]
				ret['description'] = job[:description]
				if user['admin'] == 1
          ret['user_id'] = job[:user_id]
				end
				return ret
			end
			ret['ok'] = false
			ret['error'] = "Job does not exist for this user"
			return ret
		end
		ret['ok'] = false
		ret['error'] = "Invalid or expired Session ID"
    ret
	end

	#function list_jobs: triggered when a "LIS JOBS" message is received, returns the list of jobs that belong to
	#this user (all if user is admin.)
	def list_jobs(session_id)
		#initializes the return variable
		ret = Hash.new
		#checks the validity of the session ID and stores the returning value in the variable user
		user = check_session_id(session_id)
		#check_session_id returns false if the session ID is not valid; if user is not false (the session ID is valid)
		if user
      #user_id is taken from the field 'id' from variable user
			user_id = user['id']
			job_list = Array.new
			if user['admin'] == 1
        $db["SELECT * FROM jobs"].each do |ms|
					job = Hash.new
					job['id'] = ms[:id]
					job['status'] = ms[:status]
					job['user_id'] = ms[:user_id]
					job_list.push(job)
				end
			else
				$db["SELECT * FROM jobs WHERE user_id=#{user_id}"].each do |ms|
					job = Hash.new
					job['id'] = ms[:id]
					job['status'] = ms[:status]
					job_list.push(job)
				end
			end
			ret['ok'] = true
			ret['job_list'] = job_list
			return ret
		end
		ret['ok'] = false
		ret['error'] = "Invalid or expired Session ID"
    ret
	end

	#function list_splayds: triggered when a "LIST SPLAYDS" message is received, returns a list of all registered
	#splayds, containing splayd ID, IP address, key and current status
	def list_splayds(session_id)
		#initializes the return variable
		ret = Hash.new
		if check_session_id(session_id)
      splayd_list = Array.new
			$db["SELECT * FROM splayds"].each do |ms|
				splayd=Hash.new
				splayd['splayd_id']=ms[:id]
				splayd['ip']=ms[:ip]
				splayd['status']=ms[:status]
				splayd['key']=ms[:key]
				splayd_list.push(splayd)
			end
			ret['ok'] = true
			ret['splayd_list'] = splayd_list
			return ret
		end
		ret['ok'] = false
		ret['error'] = "Invalid or expired Session ID"
    ret
	end

	#function start_session: triggered when a "START SESSION" message is received, triggers the granting of a token or session
	#ID valid for 24h, and returns this token along with the expiry date
	def start_session(username, hashed_password)
		#initializes the return variable
		ret = Hash.new
		user = $db["SELECT * FROM users WHERE login='#{username}'"].first
		if user
      hashed_password_from_db = user[:crypted_password]
			if hashed_password == hashed_password_from_db
        time_tomorrow = Time.new + 3600*24
				remember_token_expires_at = time_tomorrow.strftime("%Y-%m-%d %T")
				remember_token = Digest::SHA1.hexdigest("#{username}--#{remember_token_expires_at}")
				$db.run("UPDATE users SET remember_token='#{remember_token}', remember_token_expires_at='#{remember_token_expires_at}' WHERE login='#{username}'")
				ret['ok'] = true
				ret['session_id'] = remember_token
				ret['expires_at'] = remember_token_expires_at
				return ret
			end
		end
		ret['ok'] = false
		ret['error'] = "Not authenticated"
		return ret
	end

	#function new_user: triggered when a "NEW USER" message is received, creates a new regular user
	def new_user(username, hashed_password, admin_username, admin_hashedpassword)
		#initializes the return variable
		ret = Hash.new
		admin = $db["SELECT * FROM users WHERE login='#{admin_username}'"].first
		if admin
      if (admin['crypted_password'] == admin_hashedpassword) and (admin[:admin] == 1)
        unless $db["SELECT * FROM users WHERE login='#{username}'"].first
          time_now = Time.new.strftime("%Y-%m-%d %T")
          $db.run("INSERT INTO users SET login='#{username}', crypted_password='#{hashed_password}', created_at='#{time_now}'")
          user = $db["SELECT * FROM users WHERE login='#{username}'"].first
          ret['ok'] = true
          ret['user_id'] = user[:id]
          return ret
        end
				ret['ok'] = false
				ret['error'] = "Username exists already"
				return ret
			end
		end
		ret['ok'] = false
		ret['error'] = "Not authenticated as admin"
		return ret
	end

	#function list_users: triggered when a "LIST USERS" message is received, returns a list of the users (only for administrators)
	def list_users(admin_username, admin_hashedpassword)
		#initializes the return variable
		ret = Hash.new
		admin = $db["SELECT * FROM users WHERE login='#{admin_username}'"].first
		if admin then
			if (admin['crypted_password'] == admin_hashedpassword) and (admin[:admin] == 1)
        user_list = Array.new
				$db["SELECT * FROM users"].each do |ms|
					user=Hash.new
					user['id']=ms[:id]
					user['username']=ms[:login]
					user_list.push(user)
				end
				ret['ok'] = true
				ret['user_list'] = user_list
				return ret
			end
		end
		ret['ok'] = false
		ret['error'] = "Not authenticated as admin"
		return ret
	end

	#function change_passwd: triggered when a "CHANGE PASSWORD" message is received, modifies the password of a user
	def change_passwd(username, hashed_currentpassword, hashed_newpassword)
		#initializes the return variable
		ret = Hash.new
		user = $db["SELECT * FROM users WHERE login='#{username}'"].first
		hashed_password_from_db = user[:crypted_password]
		if hashed_currentpassword == hashed_password_from_db
			$db.run("UPDATE users SET crypted_password='#{hashed_newpassword}' WHERE login='#{username}'")
			ret['ok'] = true
			return ret
		end
		ret['ok'] = false
		ret['error'] = "Not authenticated"
    ret
	end

	#function remove_user: triggered when a "REMOVE USER" message is received, deletes a user from the user table. Only
	#administrators can delete users
	def remove_user(username, admin_username, admin_hashedpassword)
		ret = Hash.new
		admin = $db["SELECT * FROM users WHERE login='#{admin_username}'"].first
		if admin
			if (admin[:crypted_password] == admin_hashedpassword) and (admin[:admin] == 1)
				$db.run("DELETE FROM users WHERE login='#{username}'")
				ret['ok'] = true
				return ret
			end
		end
		ret['ok'] = false
		ret['error'] = "Not authenticated as admin"
		return ret
	end

	private
	#function check_session_id: generic function that checks the validity of a session ID, and returns the corresponding
	#user ID if the session ID is valid
	def check_session_id(session_id)
		user = $db["SELECT * FROM users WHERE remember_token='#{session_id}'"].first
		if user
			expires_at = user[:remember_token_expires_at]
			expires_at_time_format = Time.local(expires_at.year, expires_at.month, expires_at.day, expires_at.hour, expires_at.min, expires_at.sec)
			time_now = Time.new()
			if time_now < expires_at_time_format
				ret = Hash.new
				ret['id'] = user[:id]
				ret['admin'] = user[:admin]
				return ret
			else
				user_id = user[:id]
				$db.run("UPDATE users SET remember_token=NULL, remember_token_expires_at=NULL WHERE id=#{user_id}")
				return false
			end
		else
			false
		end
	end
end
