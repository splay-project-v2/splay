#!/bin/bash
echo "Begin basic integration test of Splay"

echo "Clean (kill and rm) docker service"
docker kill $(docker-compose ps -q) &> /dev/null
docker rm $(docker-compose ps -q) &> /dev/null

echo "Build images of docker-compose"
docker-compose build

if [ $? != 0 ] then
    echo "Fail to build images from docker-compose configuration"
    exit 1
fi

echo "Run controller - cli (db, backend also)"
docker-compose up -d controller cli

if [ $? != 0 ] then
    echo "Fail to run controller - cli (db, backend also)"
    exit 1
fi 

echo "Run two splay daemons"
docker-compose up -d --scale daemon=2

if [ $? != 0 ] then
    echo "Fail to run daemons"
    exit 1
fi

echo "Register a test user"

docker-compose exec cli python cli.py new-user Test test@test.com 123456789 123456789

if [ $? != 0 ] then 
    echo "Fail to register a test user - backend had crash ?"
    exit 1
fi

echo "See the list of splayds"
docker-compose exec cli python cli.py list-splayds

if [ $? != 0 ] then 
    echo "Fail to register a test user - backend had crash ?"
    exit 1
fi

docker-compose exec cli python cli.py submit-job -n "TEST" -s 2 app_test/



