FROM ruby:2.5.1
LABEL Description="Splay - Controller - Master process orchestrating Daemons and assigning jobs"

RUN mkdir -p /usr/splay

WORKDIR /usr/splay

RUN apt-get update -qq 
RUN apt-get -y --no-install-recommends install \
  build-essential rubygems less mysql-client default-libmysqlclient-dev libssl-dev openssl

RUN gem install json -v 2.1.0
RUN gem install minitest mysql2 sequel openssl
#openssl-nonblock dbi dbd-mysql Orbjson

ADD *.rb ./
ADD lib ./lib
ADD deploy_controller.sh .
# add deploy_web_server.sh .
RUN mkdir -p links
