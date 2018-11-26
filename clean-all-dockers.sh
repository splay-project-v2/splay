#!/usr/bin/env bash
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)

# !!! CLEAN all cache (careful with this one)
# docker rmi -f $(docker images -q)

docker-compose build

# To enter in docker image : docker run --rm -it eae3b8525da6 sh