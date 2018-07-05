-- Run with:
-- lua install_check.lua
print("------------- start testing installation -------------")

-- Lua
require"table"
require"math"
require"os"
require"io"
require"string"

print("------------- Lua Ok -------------")

-- Splay
require"splay"
require"splay.base"
require"splay.data_bits"
require"splay.misc"
require"splay.net"
require"splay.rpc"

-- Core dumped
require"splay.urpc"

print("------------- Splay Ok-------------")

-- cjson : Need to install : https://luarocks.org/modules/openresty/lua-cjson
require"json"

print("------------- Json Ok-------------")


-- LuaSocket other libraries
require"socket.ftp"
require"socket.http"
require"socket.smtp"
require"socket.tp"
require"socket.url"
require"mime"
require"ltn12"

print("------------- Socket Ok-------------")


-- LuaSec
require"ssl"

print("------------- SSL Ok-------------")

-- Luacrypto
require"crypto"

print("------------- end testing installation -------------")
print()
print("If there is no error messages, all the required libraries are ")
print("installed and found on this system.")
