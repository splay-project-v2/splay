#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
submit "app_test/raft_election.lua"

#--
get_logs 15
kill_job

#--
step "Verify the logs (1)"
if [[ ${LOGS[@]} != *"I Become the LEADER"* ]]; then
    echo "${LOGS[@]}"
    error "No leader"
fi