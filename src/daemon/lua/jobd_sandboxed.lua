--[[
       Splay ### v1.3 ###
       Copyright 2006-2011
       http://www.splay-project.org
]]

--[[
This file is part of Splay.

Splay is free software: you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published 
by the Free Software Foundation, either version 3 of the License, 
or (at your option) any later version.

Splay is distributed in the hope that it will be useful,but 
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Splayd. If not, see <http://www.gnu.org/licenses/>.
]]
--[[
NOTE:
This program is normally called by splayd, but you can too run it standalone
to replay a job or to debug.
]]

local table = require"table"
local math = require"math"
local os = require"os"
local string = require"string"
local io = require"io"

json=require"json"
splay=require"splay"
gettimeofday=splay.gettimeofday
do
	local p = print
	print = function(...)
		--p(...)
		local s,u=gettimeofday()--splay.gettimeofday()
		p(s,u, ...) --local timestamp, used when controller configured with UseSplaydTimestamps
		io.flush()
	end
end

if not splayd then
	job_file = arg[1]
end

if not job_file then
	print("You need to give a job file parameter.")
	os.exit()
end

--print("Jobd start, job file: "..job_file)

if not splayd then
	print(">> WARNING: Lua execution, memory limit for jobs will not be enforced.")
end

f = io.open(job_file)
if not f then
	print("Error reading job data")
	os.exit()
end
--print(f:read("*a"))
--job = json.decode(f:read("*a"))
local j_raw=f:read("*a")
--print("Job json:\n",j_raw)
job = json.decode(j_raw)
f:close()

if not job then
	print("Invalid job file format.")
	os.exit()
end
if job.network.list and type(job.network.list) == "string" then
    local fh = io.open(job.network.list)
    if not fh then
        print("Error reading network list data")
        os.exit()
    end
    local jnl_string = fh:read("*a")
    fh:close()
    job.network.list = json.decode(jnl_string)
end


if job.topology then
	local t_f=io.open(job.topology)
	local t_raw=t_f:read("*a")
	t_f:close()
	--local x= os.clock()
	job.topology = json.decode(t_raw)
end

if job.remove_file then
        print("Job file not deleted:", job_file)
        --os.execute("rm -fr "..job_file.." > /dev/null 2>&1")
end

-- back to global
_SPLAYD_VERSION = job._SPLAYD_VERSION

-- Set process memory limit
if job.max_mem ~= 0 then
	if splayd then
		splayd.set_max_mem(job.max_mem)
	else
		print("Cannot apply memory limitations (run from C daemon).")
		os.exit()
	end
end

-- aliases (job.me is already prepared by splayd)
if job.network.list then
	job.position = job.network.list.position
	job.nodes = job.network.list.nodes

	-- now job.nodes is a function that gives an updated view of the nodes
	job.get_live_nodes = function()
		-- if there is a timeline (trace_alt type of job)
		if job.network.list.timeline then
			-- look how much time has passed already
			local delayed_time = os.time() - job.network.list.start_time
			-- initializes the list of current nodes
			local current_nodes = {}
			-- initializes the event index (will hold the time on the timeline
			-- table that passed just before the delayed time)
			local event_index = nil
			-- for all "times"
			for i,v in ipairs(job.network.list.timeline) do
				-- if the time is bigger or equal to the delayed time
				if not (v.time < delayed_time) then
					-- if the time is strictly bigger
					if v.time > delayed_time then
						-- takes the time before this one
						event_index = i-1
					-- else ("time" exactly equal to delayed_time)
					else
						-- takes that time
						event_index = i
					end
					-- stop looking
					break
				end
			end
			-- if event index is bigger than 0
			if event_index > 0 then
				-- insert all nodes in the list of current nodes
				for i,v in ipairs(job.network.list.timeline[event_index].nodes) do
					table.insert(current_nodes, {position=v, ip=job.network.list.nodes[v].ip, port=job.network.list.nodes[v].port})
				end
				-- return the filled table
				return current_nodes
			-- if event index <= 0 there was an error
			else
				print("ERROR")
			end
			-- returns nil
			return nil
		-- if there is no timeline, it is a normal job, returns job.network.list.nodes
		else
			return job.network.list.nodes
		end
	end


	job.list_type = job.network.list.type -- head, random
end
package.cpath = package.cpath..";"..job.disk.lib_directory.."/?.so"

print(">> Job settings:")
print("Ref: "..job.ref)
print("Name: "..job.name)
print("Description: "..job.description)
print("Disk:")
print("", "max "..job.disk.max_files.." files")
print("", "max "..job.disk.max_file_descriptors.." file descriptors")
print("", "max "..job.disk.max_size.." size in bytes")

print("", "lib directoy ".. job.disk.lib_directory)
print("", "cpath : "..package.cpath)
print("Mem "..job.max_mem.." bytes of memory")
print("Network:")
print("", "max "..job.network.max_send.."/"..
		job.network.max_receive.." send/receive bytes")
print("", "max "..job.network.max_sockets.." tcp sockets")
print("", "ip "..job.me.ip)
if job.network.nb_ports > 0 then
	print("", "ports "..job.me.port.."-"..(job.me.port + job.network.nb_ports - 1))
else
	print("", "no ports")
end
if job.log and job.log.max_size then
	print("Max log size: "..job.log.max_size)
end
print()

-- To test text files or bytecode files.
--file = io.open("test_job.luac", "r")
--job.code = file:read("*a")
--file:close()
--file = io.open("out.luac", "w")
--file:write(job.code)
--file:close()

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--[[ Restricted Socket ]]--

-- We absolutly need to load restricted_socket BEFORE any library that can use
-- LuaSocket because the library could, if we don't do that, have a local copy
-- of original, non wrapped, (or non configured) socket functions.
socket = require"socket.core"

rs = require"splay.restricted_socket"
settings = job.network
settings.blacklist = job.blacklist
settings.start_port = job.me.port
settings.end_port = job.me.port + job.network.nb_ports - 1
-- If our IP seen by the controller is 127.0.0.1, it's a local experiment and we
-- disable the port range restriction because we need to contact other splayd on
-- the same machine.
if job.me.ip ~= "127.0.0.1" then
	settings.local_ip = job.me.ip
end
rs.init(settings)

socket = rs.wrap(socket)

-- Replace socket.core, unload the other
package.loaded['socket.core'] = socket

-- This module requires debug, not allowed in sandbox
require"splay.coxpcall"

--[[ Sandbox]]--

_sand_check = true
sandbox = require"splay.sandbox"
local sd=sandbox.sandboxed_denied --stub for sand'ed functions
local native_from_job = nil
if job.lib_name ~= nil and job.lib_name ~= "" then
	native_from_job = string.sub(job.lib_name,0,(#(job.lib_name) -3))
	print("Using native lib: ",native_from_job,job.lib_version)
end

sandbox.protect_env({
		io = job.disk, -- settings for restricted_io
		globals = {"_G", "_VERSION", "_SPLAYD_VERSION", "job"},
		allowed = {
			"splay.base",
			"splay.benc",
			"splay.bits",
			"splay.coxpcall",
			"splay.data_bits",
			"splay.data_bits_core",
			"splay.events",
			"splay.json",
			"splay.llenc",
			"splay.log",
			"splay.net",
			"splay.misc",
			"splay.misc_core",
			"splay.out",
			"splay.queue",
			"splay.rpc",
			"splay.rpcq",
			"splay.socket",
			"splay.urpc",
			"crypto",
			"socket",
			"socket.ftp",
			"socket.http",
			"socket.smtp",
			"socket.tp",
			"socket.url",
			"mime",
			"mime.core",
			"ltn12",
			"json",
			"socket.core",
			"splay.socket_events",
			"splay.luasocket",
			"splay.async_dns",
		    "splay.topo_socket",
		    "splay.token_bucket",
			"splay.tree",
			"splay.topo_gossip",
			native_from_job
		},
		inits = {}
	})

collectgarbage()
collectgarbage()

  -----------------------
-- The Sandbox Zone (tm) --
  -----------------------

print(">> Into sandbox !!!")
print("> Memory: "..collectgarbage("count").." KBytes")
print("> Checking sandbox...")

-- Mini sandbox check
if load~=sd or loadfile~=sd or dofile~=sd or newproxy~=sd or io.popen or os.execute
		or _sand_check or _G._sand_check then
	print("   > failed")
	os.exit()
else
	print("   > passed")
end
print()

splay_code_function, err = loadstring(job.code, "job code")
job.code = nil -- to free some memory
collectgarbage("collect")
if splay_code_function then	
	splay_code_function()
else
	print("Error loading code:", err)
end
