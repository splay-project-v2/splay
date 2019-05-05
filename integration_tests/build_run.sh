#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

DOCKER_FILE=$1
step "Begin basic integration test of Splay"

# -- 
step "Clean (kill and rm) docker service"
docker kill $(docker-compose -f $DOCKER_FILE ps -q) # &> /dev/null
docker rm $(docker-compose -f $DOCKER_FILE ps -q) # &> /dev/null

# -- 
step "Build images of docker-compose"
docker-compose -f $DOCKER_FILE build
check 'Fail to build images from docker-compose configuration'

# -- 
step "Run controller - cli - web_app (not tested) (db, backend also)"
docker-compose up -d controller cli web_app
check "Fail to run controller - cli - web_app (not tested) (db, backend also)"

# -- 
step "Run multiple (4) splay daemons"
docker-compose -f $DOCKER_FILE up -d --scale daemon=4
check "Fail to run daemons"

# -- 
step "Register a test user"
docker-compose -f $DOCKER_FILE exec cli python cli.py new-user Test test@test.com 123456789 123456789
check "Fail to register a test user - backend had crash ?"

# -- 
step "See the list of splayds"
docker-compose -f $DOCKER_FILE exec cli python cli.py list-splayds
check "Fail to print the list of splay daemon"