#!/bin/bash
docker-compose build
docker-compose up -d
source ./build/alias.sh # creates docker_rails && docker_rspec aliases
docker_rails db:migrate 2>/dev/null || docker_rails db:reset # bootstraps database if not setup