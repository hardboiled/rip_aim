#!/bin/bash
alias docker_rails='docker exec -it $(docker ps --filter "name=ripaim_web" -q) rails'
alias docker_rspec='docker exec -it $(docker ps --filter "name=ripaim_web" -q) rspec'
