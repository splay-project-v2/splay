-- test base64 library

local base64=require"base64"

print(base64.version)

function test(s)
 local a=base64.encode(s)
 local b=base64.decode(a)
 assert(b==s)
end

for i=1,9 do
 locals=string.sub("Lua-scripting-language",1,i)
 test(locals)
end

function test(p)
 for i=1,255 do
  local s=p..string.char(i)
  local a=base64.encode(s)
  local b=base64.decode(a)
  assert(b==s,i)
 end
end

test""
test"x"
test"xy"
test"xyz"

-- eof
