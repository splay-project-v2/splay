#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
submit "app_test/simple.lua"

#--
get_logs 2

#--
step "Verify the logs"
if [[ ${LOGS[@]} != *"SIMPLE.LUA START"* || ${LOGS[@]} != *"SIMPLE.LUA EXIT"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result"
fi