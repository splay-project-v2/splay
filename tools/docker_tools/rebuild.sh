#!/usr/bin/env bash
docker-compose kill
docker-compose rm -f
docker-compose build 
docker-compose up web_server
