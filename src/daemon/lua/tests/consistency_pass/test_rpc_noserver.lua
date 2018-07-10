
require"splay.base"
local rpc = require"splay.rpc"
local log = require"splay.log"
local l_o = log.new(3, "[test_rpc_noserver]")
function pong()
	return "pong"
end
local finish = false
events.run(function()
    --rpc.server(30001)
	local pong_rep, err= rpc.call({ip="127.0.0.1",port=30001}, {"pong"})	
	l_o:print("pong reply:", pong_rep, "err", err)
	assert(pong_rep==nil)
	assert(err=="connection refused")
	finish = true
end)

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n and finish == false do end
end

sleep(2)

if (finish == false) then
	error("Test fail")	
end

