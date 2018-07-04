from ubuntu:18.04
label Description="TBD"

run mkdir -p /usr/splay/lib/c
run mkdir -p /usr/splay/lib/lua

workdir /usr/splay

run apt-get update 
run apt-get -y --no-install-recommends install build-essential openssl libssl1.0 
# Due to a bug where the symbol link is not create
run apt-get -y --no-install-recommends install lua5.3 liblua5.3-0 liblua5.3-dev
run update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 10
run update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3 10

run apt-get -y --no-install-recommends install lua-socket lua-socket-dev lua-sec

env L_PATH  "/usr/splay/lib/lua"
env L_CPATH "/usr/splay/lib/c"

add *.* ./
add Makefile .  
add luacrypto ./luacrypto
add modules ./modules
add deploy.sh .

run \
  make all

run export LUA_PATH=$(lua -e 'print(package.path)') ;\
    export LUA_PATH="${LUA_PATH};/usr/splay/lib/lua/?.lua" ;\
    export LUA_CPATH=$(lua -e 'print(package.cpath)');\
    export LUA_CPATH="${LUA_CPATH};/usr/splay/lib/c/?.so" ;\
    ./install.sh

cmd ["./deploy.sh"]
