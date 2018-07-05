#!/usr/bin/env bash
docker-compose kill
docker-compose rm -f
docker-compose build 
docker-compose up -d db 
docker-compose up -d controller 

docker-compose scale daemon=1

docker-compose logs -f controller
