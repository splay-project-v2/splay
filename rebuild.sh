#!/usr/bin/env bash
docker-compose kill
docker-compose rm -f
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker-compose build 
docker-compose up -d web_server
docker-compose scale daemon=5
#docker-compose up -d splayweb
