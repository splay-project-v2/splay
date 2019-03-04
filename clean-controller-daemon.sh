#!/usr/bin/env bash

docker-compose kill controller
docker-compose kill daemon
docker-compose rm -f controller
docker-compose rm -f daemon

docker-compose build controller
docker-compose build daemon