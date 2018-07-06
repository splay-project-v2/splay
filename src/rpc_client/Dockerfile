from ubuntu:18.04
label Description="TBD"

run mkdir /usr/splay
workdir /usr/splay

run apt-get update 
RUN apt-get -y --no-install-recommends install lua5.3 liblua5.3-0 liblua5.3-dev lua-socket lua-socket-dev
# Due to a bug of lua 5.3 package where the symbol link is not create
RUN update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 10
RUN update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3 10

add commands/* ./
add lib ./lib
add install_check.lua ./
add sample.lua ./

run lua install_check.lua