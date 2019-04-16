#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

step "Begin basic integration test of Splay"

# -- 
step "Clean (kill and rm) docker service"
docker kill $(docker-compose ps -q) # &> /dev/null
docker rm $(docker-compose ps -q) # &> /dev/null

# -- 
step "Build images of docker-compose"
docker-compose build
checkError 'Fail to build images from docker-compose configuration'

# -- 
step "Run controller - cli (db, backend also)"
docker-compose up -d controller cli
checkError "Fail to run controller - cli (db, backend also)"

# -- 
step "Run two splay daemons"
docker-compose up -d --scale daemon=2
checkError "Fail to run daemons"

# -- 
step "Register a test user"
docker-compose exec cli python cli.py new-user Test test@test.com 123456789 123456789
checkError "Fail to register a test user - backend had crash ?"

# -- 
step "See the list of splayds"
docker-compose exec cli python cli.py list-splayds
checkError "Fail to print the list of splay daemon"

#--
step "Submit the a simple job"
docker-compose exec cli python cli.py submit-job -n "TEST" -s 2 app_test/simple.lua
checkError "Fail to submit the job"

#--
step "Wait few second and fetch list of jobs"
sleep 2
docker-compose exec cli python cli.py list-jobs
checkError "Fail to get the list of jobs"

#--
step "Get logs of the job and find if the correct result is into"
