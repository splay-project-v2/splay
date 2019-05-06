#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
submit "app_test/crash_point.lua"

#--
sleep 10
kill_job

#--
get_logs 5

#--
step "Verify the logs (1)"
if [[ ${LOGS[@]} != *"CRASH_POINT.LUA START"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (START)"
fi

#--
step "Verify the logs (2)"
if [[ ${LOGS[@]} != *"RECOVERY CRASH 1"* ]]; then
    echo "${LOGS[@]}"
    error "Recovery crash not found"
fi

step "Verify the logs (3)"
if [[ ${LOGS[@]} != *"STOP CRASH 2"* ]]; then
    echo "${LOGS[@]}"
    error "Stop crash not found"
fi