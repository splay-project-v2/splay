FROM ruby:2.5.1
label Description="TBD"

run mkdir -p /usr/splay

workdir /usr/splay

run apt-get update -qq
run apt-get -y --no-install-recommends install \
  build-essential rubygems less mysql-client default-libmysqlclient-dev libssl-dev openssl

run gem install json -v 2.1.0
run gem install openssl mysql2 sequel Orbjson

add cli-server ./cli-server
add lib ./lib
add deploy_web_server.sh .
