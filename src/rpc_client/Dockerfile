from ubuntu:18.04
label Description="TBD"

run mkdir /usr/splay
workdir /usr/splay

run apt-get update && \
  apt-get -y --no-install-recommends install \
  lua5.1 lua5.1-socket liblua5.1-json

add *.* ./
add lib ./lib
