#!/bin/bash
docker-compose build
docker-compose up -d

# bootstraps database if not setup
docker exec -t $(docker ps --filter "name=ripaim_web" -q) \
  bash -l -c 'bin/rails db:migrate 2>/dev/null || bin/rails db:reset'