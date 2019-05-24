#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
submit "app_test/raft_election.lua"

#--
get_logs 15

#--
step "Verify the logs (1)"
if [[ ${LOGS[@]} != *"RAFT.LUA START"* || ${LOGS[@]} != *"RAFT.LUA EXIT"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (START - EXIT)"
fi

#--
step "Verify the logs (2)"
if [[ ${LOGS[@]} != *"I become the LEADER"* ]]; then
    echo "${LOGS[@]}"
    error "No leader"
fi