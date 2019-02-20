#!/usr/bin/env bash
#docker-compose kill
#docker-compose rm -f
#docker kill $(docker ps -q)
#docker rm $(docker ps -a -q)
docker-compose build
docker-compose up -d backend
docker-compose up -d web_app
docker-compose up -d --scale daemon=5

