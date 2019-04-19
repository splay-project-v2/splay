#!/usr/bin/env bash
docker kill $(docker-compose ps -q) # &> /dev/null
docker rm $(docker-compose ps -q) # &> /dev/null

# !!! CLEAN all cache (careful with this one)
# docker rmi -f $(docker images -q)

# To enter in docker image : docker run --rm -it eae3b8525da6 sh