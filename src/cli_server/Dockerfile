FROM ruby:2.5.1
LABEL Description="Splay - Web Server - Receive HTTP commands to interact with Controller"

RUN mkdir -p /usr/splay
RUN mkdir -p /usr/splay/cli_server/logs

WORKDIR /usr/splay

RUN apt-get update -qq
RUN apt-get -y --no-install-recommends install \
  build-essential rubygems less mysql-client default-libmysqlclient-dev libssl-dev openssl

RUN gem install json -v 2.1.0
RUN gem install openssl mysql2 sequel

ADD cli_server/*.rb ./cli_server
ADD controller/lib ./lib
ADD cli_server/deploy_cli_server.sh ./

CMD ["./deploy_cli_server.sh"]
