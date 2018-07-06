FROM ubuntu:18.04
LABEL Description="Splay - Daemon - daemon act as a node in the splay-project capable perform jobs"

# Mayby better image : https://hub.docker.com/r/abaez/lua/

RUN mkdir -p /usr/splay/lib/c
RUN mkdir -p /usr/splay/lib/lua

WORKDIR /usr/splay

RUN apt-get update 
RUN apt-get -y --no-install-recommends install build-essential openssl libssl1.0 
RUN apt-get -y --no-install-recommends install lua5.3 liblua5.3-0 liblua5.3-dev
# Due to a bug of lua 5.3 package where the symbol link is not create
RUN update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 10
RUN update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3 10

RUN apt-get -y --no-install-recommends install lua-socket lua-socket-dev lua-sec

ENV L_PATH  "/usr/splay/lib/lua"
ENV L_CPATH "/usr/splay/lib/c"

ADD certificats/*.cnf ./
ADD bash/*.sh ./
ADD c/*.c ./
ADD c/*.h ./
ADD c/so_module ./
ADD c/c_exec ./
ADD c/Makefile ./
ADD lua/*.lua ./
ADD lua/modules ./modules 
ADD lua/tests ./lua_tests

RUN make all

RUN export LUA_PATH=$(lua -e 'print(package.path)') ;\
    export LUA_PATH="${LUA_PATH};/usr/splay/lib/lua/?.lua" ;\
    export LUA_CPATH=$(lua -e 'print(package.cpath)');\
    export LUA_CPATH="${LUA_CPATH};/usr/splay/lib/c/?.so" ;\
    ./install.sh

RUN chmod +x ./clean_src.sh ; \
    ./clean_src.sh

# Not very useful for now
RUN export LUA_PATH=$(lua -e 'print(package.path)') ;\
    export LUA_PATH="${LUA_PATH};/usr/splay/lib/lua/?.lua" ;\
    export LUA_CPATH=$(lua -e 'print(package.cpath)');\
    export LUA_CPATH="${LUA_CPATH};/usr/splay/lib/c/?.so" ;\
    cd ./lua_tests && lua all_tests.lua

CMD ["./deploy.sh"]
