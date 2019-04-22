#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
submit "app_test/simple_net.lua"

#--
get_logs 10

#--
step "Verify the logs (1)"
if [[ ${LOGS[@]} != *"SIMPLE_NET.LUA START"* || ${LOGS[@]} != *"SIMPLE_NET.LUA EXIT"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (START - EXIT)"
fi

#--
step "Verify the logs (2)"
if [[ ${LOGS[@]} != *"I received : I AM 1"* || ${LOGS[@]} != *"I received : I AM 2"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (received data)"
fi


step "The Network Test is successful"