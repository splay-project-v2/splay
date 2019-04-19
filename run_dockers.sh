#!/usr/bin/env bash
docker-compose build
docker-compose up -d web_app
docker-compose up -d controller
docker-compose up -d --scale daemon=5

