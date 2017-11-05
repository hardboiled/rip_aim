#!/bin/bash
alias docker_rails='docker exec -it $(docker ps --filter "name=ripaim_web" -q) rails'
alias docker_rspec='docker exec -it $(docker ps --filter "name=ripaim_web" -q) rspec'

# for byebug/pry
alias attach_to_rails='docker attach $(docker ps --filter "name=ripaim_web" -q)'
