FROM ubuntu:18.04
LABEL Description="Splay - RPC Client - App able to launch lua script to get/push information to the controller"

RUN mkdir /usr/splay
WORKDIR /usr/splay

RUN apt-get update 
RUN apt-get -y --no-install-recommends install lua5.3 liblua5.3-0 liblua5.3-dev lua-socket lua-socket-dev
# Due to a bug of lua 5.3 package where the symbol link is not create
RUN update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 10
RUN update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3 10

ADD commands/* ./
ADD lib ./lib
ADD install_check.lua ./
ADD sample.lua ./
ADD ./applications ./app

RUN lua install_check.lua