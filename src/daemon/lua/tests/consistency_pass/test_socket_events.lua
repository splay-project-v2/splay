local se =require"splay.socket_events"
assert(se.wrap)
assert(se._NAME=="splay.socket_events")

-- Check if function of socket is available
local socket = require("socket")
assert(socket._VERSION)
assert(socket.dns) --	table: 0x7fc8b1c0fc60
assert(socket._SETSIZE)
assert(socket.protect) --	function: 0x105c0bff0
assert(socket.choose) --	function: 0x7fc8b1c06310
assert(socket.try) --	function: 0x7fc8b1c062e0
assert(socket.connect4) --	function: 0x7fc8b1c0fa50
assert(socket.udp6) --	function: 0x105c0d620
assert(socket.tcp6) --	function: 0x105c0cd30
assert(socket.source) --	function: 0x7fc8b1c0ac40
assert(socket.skip) --	function: 0x105c08520
assert(socket.bind) --	function: 0x7fc8b1c06280
assert(socket.newtry) --	function: 0x105c0c010
assert(socket.BLOCKSIZE)
assert(socket.sleep) --	function: 0x105c08680
assert(socket.sinkt) --	table: 0x7fc8b1c0dd60
assert(socket.udp) --	function: 0x105c0d630
assert(socket.sourcet) --	table: 0x7fc8b1c0dd20
assert(socket.connect6) --	function: 0x7fc8b1c0fab0
assert(socket.connect) --	function: 0x105c0c990
assert(socket.tcp) --	function: 0x105c0cd40
assert(socket.__unload) --	function: 0x105c08510
assert(socket.select) --	function: 0x105c0c580
assert(socket.gettime) --	function: 0x105c087a0
assert(socket.sink) --	function: 0x7fc8b1c0ddd0
assert(socket.udp)
assert(socket.tcp)
assert(socket.newtry)
assert(socket.protect)

local socket_wrapped_by_socket_events = se.wrap(socket)
assert(socket_wrapped_by_socket_events.bind)

local lsh = require"splay.luasocket"
local wrapped_socket = lsh.wrap(socket_wrapped_by_socket_events)
assert(wrapped_socket.bind)
