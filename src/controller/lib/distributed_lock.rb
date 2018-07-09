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

require 'thread'

# Distributed DB locking, for locks between different hosts (or different local
# instance, even if it's not the most efficient way in that case).
class DistributedLock

	@@mutex = Mutex.new
	@@db = nil

	def initialize(name)
		@name = name
		@lock = false
	end

	def get
		DistributedLock::get(@name)
	end

	def release
		DistributedLock::release(@name)
	end

	def self.get(name)
		unless @@db
			@@db = DBUtils.get_new
		end
		ok = false
		until ok
			@@mutex.synchronize do
				# TO TEST (transaction) or watch code, must be a Mutex like mine... +
				# BEGIN and COMMIT
				#$dbt.transaction do |dbt|
				@@db.transaction do
					locks = @@db.from(:locks).where(id: 1).first
					if locks[name.to_sym]
						if locks[name.to_sym] == 0
							@@db.from(:locks).where(id: 1).update(name.to_sym => '1')
							ok = true
						end
					else
						$log.error("Trying to get a non existant lock: #{name}")
						ok = true
					end
				end
			end
		end
	end

	def self.release(name)
		@@mutex.synchronize do
			#@@db.do "BEGIN"
			@@db.run("UPDATE locks SET #{name.to_sym}='0' WHERE id ='1'")
			#@@db.do "COMMIT"
		end
	end
end
