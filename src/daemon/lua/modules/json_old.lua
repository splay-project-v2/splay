
--------------- LEO modified !!!

-----------------------------------------------------------------------------
-- JSON4Lua: JSON encoding / decoding support for the Lua language.
-- json Module.
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9.20
-- This module is released under the The GNU General Public License (GPL).
-- Please see LICENCE.txt for details.
--
-- USAGE:
-- This module exposes two functions:
--   encode(o)
--     Returns the table / string / boolean / number / nil / json.null value as a JSON-encoded string.
--   decode(json_string)
--     Returns a Lua object populated with the data encoded in the JSON string json_string.
--
-- REQUIREMENTS:
--   compat-5.1 if using Lua 5.0
--
-- CHANGELOG
--   CURRENT Modified by Valerio Schiavoni: encode is now completely rewritten: only 1 table.concat 

--   0.9.20 Introduction of local Lua functions for private functions (removed _ function prefix). 
--          Fixed Lua 5.1 compatibility issues.
--   		Introduced json.null to have null values in associative arrays.
--          encode() performance improvement (more than 50%) through table.concat rather than ..
--          Introduced decode ability to ignore /**/ comments in the JSON string.
--   0.9.10 Fix to array encoding / decoding to correctly manage nil/null values in arrays.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
local math = require('math')
local string = require("string")
local table = require("table")

--local base = _G
local type = type
local tostring = tostring
local pairs = pairs
local print = print
local loadstring = loadstring
local assert = assert
-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
local _M={}

-- Public functions

-- Private functions
local decode_scanArray
local decode_scanComment
local decode_scanConstant
local decode_scanNumber
local decode_scanObject
local decode_scanString
local decode_scanWhitespace
local encodeString
local isArray
local isEncodable

local replace_unicode
local hex_char_to_num
local json_uchar_to_chars

-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------

local function encode_table(v,out)
	local vtype = type(v)
	-- Handle nil values
	if v==nil or vtype=='function' then
		out[out.n] = 'null'
		out.n = out.n + 1
	-- Handle strings
	elseif vtype=='string' then
		out[out.n] = '"'
		out.n = out.n + 1		
		out[out.n] = encodeString(v)
		out.n = out.n + 1				
		out[out.n] = '"'
		out.n = out.n + 1
	-- Handle booleans or numbers
	elseif vtype=='number' or vtype=='boolean' then		
		out[out.n] = tostring(v)
		out.n = out.n + 1
	-- Handle tables
	elseif vtype=='table' then
		--local rval = {}
		-- Consider arrays separately
		local bArray, maxCount = _M.isArray(v)
		if bArray then
			out[out.n] = '['
			out.n = out.n + 1
			for i = 1,maxCount do
				encode_table(v[i],out)
				if i<=(maxCount-1) then
					out[out.n] = ','
					out.n = out.n + 1
				end
			end
			out[out.n] = ']'
			out.n = out.n + 1
	   	else	-- An object, not an array
	   		out[out.n] = '{'
	   		out.n = out.n + 1
			
	   		for i,j in pairs(v) do
	   			if _M.isEncodable(i) and _M.isEncodable(j) then
	   				out[out.n] = '"'
	   				out.n = out.n + 1
        	
	   				out[out.n] = _M.encodeString(i)
	   				out.n = out.n + 1
        	
	   				out[out.n] = '"'
	   				out.n = out.n + 1
        	
	   				out[out.n] = ':'
	   				out.n = out.n + 1
        			
					encode_table(j,out)
					
	   				out[out.n] = ','
	   				out.n = out.n + 1
	   			end
	   		end
			
			out.n=out.n-1 --HACK to go backward and remove trailing comma
			
	   		out[out.n] = '}'
	   		out.n = out.n + 1
	   	end
	end
end

--- Encodes an arbitrary Lua object / variable.
-- @param v The Lua object / variable to be JSON encoded.
-- @return String containing the JSON encoding in internal Lua string format (i.e. not unicode)
function _M.encode (v)
  	local out = { n=1 }
  	encode_table(v, out)
	--for k,v in pairs(out) do
	--	print(k,v)
	--end
  	return table.concat(out)
end


--- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
-- @param s The string to scan.
-- @param [startPos] Optional starting position where the JSON string is located. Defaults to 1.
-- @param Lua object, number The object that was scanned, as a Lua table / string / number / boolean or nil,
-- and the position of the first character after
-- the scanned JSON object.
function _M.decode(s, startPos)
  startPos = startPos and startPos or 1
  startPos = decode_scanWhitespace(s,startPos)
  --assert(startPos<=string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
  local curChar = string.sub(s,startPos,startPos)
--print(startPos, "curchar: ", curChar, string.sub(s, startPos, startPos + 40))
  -- Object
  if curChar=='{' then
    return decode_scanObject(s,startPos)
  end
  -- Array
  if curChar=='[' then
    return decode_scanArray(s,startPos)
  end
  -- Number
  if string.find("+-0123456789.e", curChar, 1, true) then
    return decode_scanNumber(s,startPos)
  end
  -- String
  if curChar==[["]] or curChar==[[']] then
    return decode_scanString(s,startPos)
  end
  if string.sub(s,startPos,startPos+1)=='/*' then
    return decode(s, decode_scanComment(s,startPos))
  end
  -- Otherwise, it must be a constant
  return decode_scanConstant(s,startPos)
end

--- The null function allows one to specify a null value in an associative array (which is otherwise
-- discarded if you set the value with 'nil' in Lua. Simply set t = { first=json.null }
function _M.null()
  return null -- so json.null() will also return null ;-)
end
-----------------------------------------------------------------------------
-- Internal, PRIVATE functions.
-- Following a Python-like convention, I have prefixed all these 'PRIVATE'
-- functions with an underscore.
-----------------------------------------------------------------------------

--- Scans an array from JSON into a Lua object
-- startPos begins at the start of the array.
-- Returns the array and the next starting position
-- @param s The string being scanned.
-- @param startPos The starting position for the scan.
-- @return table, int The scanned array as a table, and the position of the next character to scan.
function _M.decode_scanArray(s,startPos)
  local array = {}	-- The return value
  local stringLen = string.len(s)
  --assert(string.sub(s,startPos,startPos)=='[','decode_scanArray called but array does not start at position ' .. startPos .. ' in string:\n'..s )
  startPos = startPos + 1
  -- Infinite loop for array elements
		
	-- LEO leo
	-- there is a missing local index that discard nil when they are inserted
	-- I will add a position counter
	local pos = 1
  repeat
    startPos = _M.decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen,'JSON String ended unexpectedly scanning array.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar==']') then
      return array, startPos+1
    end
    if (curChar==',') then
      startPos = _M.decode_scanWhitespace(s,startPos+1)
    end
    assert(startPos<=stringLen, 'JSON String ended unexpectedly scanning array.')
    object, startPos = decode(s,startPos)
--print("array", object, startPos)
--    table.insert(array,object)
		table.insert(array, pos, object)
		pos = pos + 1
  until false
end

--- Scans a comment and discards the comment.
-- Returns the position of the next character following the comment.
-- @param string s The JSON string to scan.
-- @param int startPos The starting position of the comment
function _M.decode_scanComment(s, startPos)
  assert( string.sub(s,startPos,startPos+1)=='/*', "decode_scanComment called but comment does not start at position " .. startPos)
  local endPos = string.find(s,'*/',startPos+2)
  assert(endPos~=nil, "Unterminated comment in string at " .. startPos)
  return endPos+2  
end

--- Scans for given constants: true, false or null
-- Returns the appropriate Lua type, and the position of the next character to read.
-- @param s The string being scanned.
-- @param startPos The position in the string at which to start scanning.
-- @return object, int The object (true, false or nil) and the position at which the next character should be 
-- scanned.
function _M.decode_scanConstant(s, startPos)
  local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
  local constNames = {"true","false","null"}

  for i,k in pairs(constNames) do
		--print ("[" .. string.sub(s,startPos, startPos + string.len(k) -1) .."]", k)
    if string.sub(s,startPos, startPos + string.len(k) -1 )==k then
--print(consts[k], startPos + string.len(k))
      return consts[k], startPos + string.len(k)
    end
  end
  assert(nil, 'Failed to scan constant from string ' .. s .. ' at starting position ' .. startPos)
end

--- Scans a number from the JSON encoded string.
-- (in fact, also is able to scan numeric +- eqns, which is not
-- in the JSON spec.)
-- Returns the number, and the position of the next character
-- after the number.
-- @param s The string being scanned.
-- @param startPos The position at which to start scanning.
-- @return number, int The extracted number and the position of the next character to scan.
function _M.decode_scanNumber(s,startPos)
  local endPos = startPos+1
  local stringLen = string.len(s)
  local acceptableChars = "+-0123456789.e"
  while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true)
	and endPos<=stringLen
	) do
    endPos = endPos + 1
  end
  local stringValue = 'return ' .. string.sub(s,startPos, endPos-1)
  local stringEval = loadstring(stringValue)
  assert(stringEval, 'Failed to scan number [ ' .. stringValue .. '] in JSON string at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos
end

--- Scans a JSON object into a Lua object.
-- startPos begins at the start of the object.
-- Returns the object and the next starting position.
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return table, int The scanned object as a table and the position of the next character to scan.
function _M.decode_scanObject(s,startPos)
  local object = {}
  local stringLen = string.len(s)
  local key, value
  assert(string.sub(s,startPos,startPos)=='{','decode_scanObject called but object does not start at position ' .. startPos .. ' in string:\n' .. s)
  startPos = startPos + 1
  repeat
    startPos = decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly while scanning object.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar=='}') then
      return object,startPos+1
    end
    if (curChar==',') then
      startPos = decode_scanWhitespace(s,startPos+1)
    end
    assert(startPos<=stringLen, 'JSON string ended unexpectedly scanning object.')
    -- Scan the key
    key, startPos = decode(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    startPos = decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    assert(string.sub(s,startPos,startPos)==':','JSON object key-value assignment mal-formed at ' .. startPos)
    startPos = decode_scanWhitespace(s,startPos+1)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    value, startPos = decode(s,startPos)
    object[key]=value
  until false	-- infinite loop while key-value pairs are found
end

--- Scans a JSON string from the opening inverted comma or single quote to the
-- end of the string.
-- Returns the string extracted as a Lua string,
-- and the position of the next non-string character
-- (after the closing inverted comma or single quote).
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return string, int The extracted string as a Lua string, and the next character to parse.
function _M.decode_scanString(s,startPos)
  assert(startPos, 'decode_scanString(..) called without start position')
  local startChar = string.sub(s,startPos,startPos)
  assert(startChar==[[']] or startChar==[["]],'decode_scanString called for a non-string')
  local escaped = false
  local endPos = startPos + 1
  local bEnded = false
  local stringLen = string.len(s)
  repeat
    local curChar = string.sub(s,endPos,endPos)
    if not escaped then	
      if curChar==[[\]] then
        escaped = true
      else
        bEnded = curChar==startChar
      end
    else
      -- If we're escaped, we accept the current character come what may
      escaped = false
    end
    endPos = endPos + 1
    --assert(endPos <= stringLen+1, "String decoding failed: unterminated string at position " .. endPos)
  until bEnded
  
  -- replace the unicode json encoding
  local stringValue = 'return ' .. _M.replace_unicode(string.sub(s, startPos, endPos-1))

  local stringEval = loadstring(stringValue)
  --assert(stringEval, 'Failed to load string [ ' .. stringValue .. '] in JSON4Lua.decode_scanString at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos  
end

--- Scans a JSON string skipping all whitespace from the current start position.
-- Returns the position of the first non-whitespace character, or nil if the whole end of string is reached.
-- @param s The string being scanned
-- @param startPos The starting position where we should begin removing whitespace.
-- @return int The first position where non-whitespace was encountered, or string.len(s)+1 if the end of string
-- was reached.
function _M.decode_scanWhitespace(s,startPos)
  local whitespace=" \n\r\t"
  local stringLen = string.len(s)
  while ( string.find(whitespace, string.sub(s,startPos,startPos), 1, true)  and startPos <= stringLen) do
    startPos = startPos + 1
  end
  return startPos
end

--- Encodes a string to be JSON-compatible.
-- This just involves back-quoting inverted commas, back-quotes and newlines, I think ;-)
-- @param s The string to return as a JSON encoded (i.e. backquoted string)
-- @return The string appropriately escaped.
function _M.encodeString(s)
  -- LEO Leo put that first !
  s = string.gsub(s,'\\','\\\\')
  s = string.gsub(s,'"','\\"')
  --s = string.gsub(s,"'","\\'")
  s = string.gsub(s,"/","\\/")
  s = string.gsub(s,'\b','\\b')
  s = string.gsub(s,'\f','\\f')
  s = string.gsub(s,'\n','\\n')
  s = string.gsub(s,'\t','\\t')
  s = string.gsub(s,'\r','\\r')
  return s 
end

-- Determines whether the given Lua type is an array or a table / dictionary.
-- We consider any table an array if it has indexes 1..n for its n items, and no
-- other data in the table.
-- I think this method is currently a little 'flaky', but can't think of a good way around it yet...
-- @param t The table to evaluate as an array
-- @return boolean, number True if the table can be represented as an array, false otherwise. If true,
-- the second returned value is the maximum
-- number of indexed elements in the array. 
function _M.isArray(t)
  -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable 
  -- (with the possible exception of 'n')
  local maxIndex = 0
  for k,v in pairs(t) do
    if (type(k)=='number' and math.floor(k)==k and 1<=k) then	-- k,v is an indexed pair
      if (not _M.isEncodable(v)) then return false end	-- All array elements must be encodable
      maxIndex = math.max(maxIndex,k)
    else
      if (k=='n') then
        if v ~= table.getn(t) then return false end  -- False if n does not hold the number of elements
      else -- Else of (k=='n')
        if _M.isEncodable(v) then return false end
      end  -- End of (k~='n')
    end -- End of k,v not an indexed pair
  end  -- End of loop across all pairs
  return true, maxIndex
end

--- Determines whether the given Lua object / table / variable can be JSON encoded. The only
-- types that are JSON encodable are: string, boolean, number, nil, table and json.null.
-- In this implementation, all other types are ignored.
-- @param o The object to examine.
-- @return boolean True if the object should be JSON encoded, false if it should be ignored.
function _M.isEncodable(o)
  local t = type(o)
  return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or (t=='function' and o==null) 
end

-- LEO additions --

-- to check if we have the right version...
function _M.leo()
	return true
end

-- New version LEO leo
function _M.replace_unicode(s)
	local o, i, o_i, escape, c = {}, 1, 1, false, nil
	while i <= string.len(s) do
		c = string.sub(s, i, i)
		if escape == false and c == [[\]] then
			escape = true
		else
			if escape == true and c == "u" then
				o[o_i] = _M.json_uchar_to_chars(string.sub(s, i + 1, i + 4))
				o_i = o_i + 1
				i = i + 4
			else
				if escape == true then
					o[o_i] = [[\]]
					o_i = o_i + 1
				end
				o[o_i] = c
				o_i = o_i + 1
			end
			escape = false
		end
		i = i + 1
	end
	return table.concat(o)
end

function _M.replace_unicode_old(s)
	out = ''
	escape = false
	i = 1
	while i <= string.len(s) do
		c = string.sub(s, i, i)
		if escape == false and c == [[\]] then
			escape = true
		else
			if escape == true and c == "u" then
				out = out.._M.json_uchar_to_chars(string.sub(s, i + 1, i + 4))
				i = i + 4
			else
				if escape == true then
					out = out..[[\]]
				end
				out = out..c
			end
			escape = false
		end
		i = i + 1
	end
	return out
end

function _M.hex_char_to_num(c)
	c = string.byte(string.lower(c))
	if c >= 97 and c <= 102 then
		c = c - 87
	else
		assert(c >= 48 and c <= 58, "not valid hex char")
		c = c - 48
	end
	return c
end

-- Replace a 4 byte hex ascii (utf-16) in one or two bytes.
function _M.json_uchar_to_chars(s)
	a = hex_char_to_num(string.sub(s, 1, 1))
	b = hex_char_to_num(string.sub(s, 2, 2))
	c = hex_char_to_num(string.sub(s, 3, 3))
	d = hex_char_to_num(string.sub(s, 4, 4))
	out = ''
	if a ~= 0 or b ~= 0 then
		out = out..string.char(a * 16 + b)
	end
	return out..string.char(c * 16 + d)
end

return _M