#!/usr/bin/env bash
docker-compose kill
docker-compose build 
docker-compose up -d db 
sleep 20
docker-compose up -d controller 
docker-compose logs -f controller
