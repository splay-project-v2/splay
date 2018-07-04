FROM ruby:2.5.1
label Description="TBD"

run mkdir -p /usr/splay

workdir /usr/splay

run apt-get update -qq 
run apt-get -y --no-install-recommends install \
  build-essential rubygems less mysql-client default-libmysqlclient-dev libssl-dev openssl

run gem install json -v 2.1.0
run gem install mysql2 sequel openssl
#openssl-nonblock dbi dbd-mysql Orbjson

add *.rb ./
add lib ./lib
add deploy_controller.sh .
# add deploy_web_server.sh .
run mkdir -p links
