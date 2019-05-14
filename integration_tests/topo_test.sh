#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
JOB="app_test/simple_topo_lat.lua"
TOPO="app_test/topo_2_lat.xml"

#--
submit $JOB $TOPO

#--
get_logs 14

#--
step "Verify the logs (1)"
if [[ ${LOGS[@]} != *"SIMPLE_TOPO.LUA START"* || ${LOGS[@]} != *"SIMPLE_TOPO.LUA EXIT"* ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (START - EXIT)"
fi

#--
step "Verify the logs (2)"
PAT="FINAL RTT : [0-9]+\.[0-9]* sec"
if ! [[ ${LOGS[@]} =~ $PAT ]]; then
    echo "${LOGS[@]}"
    error "The logs don't contain the correct result (rtt)"
fi

#--
step "Verify the RTT (need to be greater 1.25, check topology used)"
# Get only one of Rtt, maybe check all of then ?
RTT=$(echo ${LOGS[@]} | grep -oP -m 1 "FINAL RTT : \K[0-9]+\.[0-9]+" | head -1)
check "Can't get the RTT"

echo "RTT = ${RTT} sec"
if [ $(bc -l <<< "${RTT} > 1.2499") -eq 0 ]; then
    echo "${LOGS[@]}"
    error "RTT Can't be smaller than 1.2499, topo_socket doesn't work ?"
fi

#--
# step "Test the speed of a topology"

#--
# JOB="app_test/simple_topo_speed.lua"
# TOPO="app_test/topo_2_speed.xml"

#--
# submit $JOB $TOPO