from ubuntu:18.04
label Description="TBD"

run mkdir -p /usr/splay/lib/c
run mkdir -p /usr/splay/lib/lua

workdir /usr/splay

run apt-get update 
run apt-get -y --no-install-recommends install \
        build-essential openssl libssl1.0 \
        lua5.1 liblua5.1-0 liblua5.1-0-dev \
        lua-socket lua-socket-dev lua-sec

env L_PATH  "/usr/splay/lib/lua"
env L_CPATH "/usr/splay/lib/c"

add *.* ./
add Makefile .  
add luacrypto ./luacrypto
add modules ./modules
add deploy.sh .

run \
  export LUA_PATH=$(lua -e 'print(package.path)') ; \
  export LUA_PATH="${LUA_PATH};/usr/splay/lib/lua/?.lua" ; \
  export LUA_CPATH=$(lua -e 'print(package.cpath)') ; \
  export LUA_CPATH="${LUA_CPATH};/usr/splay/lib/c/?.so" ; \
  echo "${LUA_PATH}\n\n${LUA_CPATH}" ; \ 
  make all && ./install.sh

cmd ["./deploy.sh"]
