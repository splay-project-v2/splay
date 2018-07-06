local s = require("string")

total = 0
fail = 0

GREEN='\27[32m'
RED='\27[31m'
NC='\27[0m'

local function getFiles(mask)
    local files = {}
    local tmpfile = '/tmp/stmp.txt'
    os.execute('ls -1 '..mask..' > '..tmpfile)
    local f = io.open(tmpfile)
    if not f then return files end  
    local k = 1
    for line in f:lines() do
       files[k] = line
       k = k + 1
    end
    f:close()
    return files
end

local function errorCall (x)
    print(RED.." - Test Fail : "..x..NC)
    fail = fail + 1
end

local function testDirectory(folder_regex)
    print(" -- TEST Folder : "..folder_regex)
    local files_table = getFiles(folder_regex)
    for key,value in pairs(files_table) do 
        total = total +  1
        local req = s.sub(value, 0,s.len(value)-4)
        print(" - Test file : "..value.." ("..req..")")
        local status, err, ret = xpcall(require, errorCall, req)
        if status then
            print(GREEN.." - Test Success - "..NC)
        end
    end
end

testDirectory("consistency_pass/*.lua")
-- testDirectory("performance_pass/*.lua")
-- testDirectory("consistency_fail/*.lua")
-- testDirectory("performance_fail/*.lua")

print("Fail : "..fail.."/"..total)