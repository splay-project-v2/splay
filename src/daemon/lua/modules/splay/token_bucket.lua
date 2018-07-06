--[[
	Splayd
	Copyright 2011 - Valerio Schiavoni (University of Neuchâtel)
	http://www.splay-project.org
]]

--[[
Implementation of the token_bucket algorithm.
Freely inspired by http://code.activestate.com/recipes/511490/ 
--]]

local log=require"splay.log"
local misc=require"splay.misc"
local math=require"math"
local assert=assert
local setmetatable = setmetatable

local _M = {}

--[[ DEBUG ]]--
local l_o = log.new(1, "[splay.token_bucket]")

function _M.new(toks,rate,cap)
	
	local bucket ={}
	local tokens=toks*1000 or 1000*1024*1024 --buffer size
	l_o:debug("Initial tokens:",tokens)
	local capacity=cap or tokens
	l_o:debug("Capacity:", capacity)
	local fill_rate=rate or 1 -- refill 1 token x second, up to 'capacity'
	l_o:debug("Fill Rate:", fill_rate,"token/sec") 
	
	local timestamp=misc.time() --init
	
	function bucket.consume(toks)
		if toks<=tokens then
			tokens=tokens-toks
			return true
		else
			return false
		end
	end
	
	function bucket.get_tokens()
		now=misc.time()
		l_o:debug("tb.get_tokens(), tokens:",tokens)
		if tokens<capacity then
			--refill the bucket, according to the elapsed time since last check
			--and the fill_rate
			delta=fill_rate*(now-timestamp)
			l_o:debug("delta:", delta)
			tokens= math.min(capacity, tokens+delta)
			l_o:debug("get_tokens(): Remaining tokens:",tokens,"("..((tokens/capacity)*100).." %)")
		end
		timestamp=now
		return tokens		
	end
	
	return bucket
end

return _M
