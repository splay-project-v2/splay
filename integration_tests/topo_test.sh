#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
step "Submit a job using network sockets"
JOB_RES=$(docker-compose exec cli python cli.py submit-job -n "TEST" -s 2 app_test/simple_topo.lua -t app_test/topo_2.xml)
check "Fail to submit the job" "\n" "${JOB_RES[@]}"

ID_JOB=$(echo "${JOB_RES[@]}" | grep -oP "Job ID\s+:\s\K(\d+)")
#--
step "Wait few seconds and fetch list of jobs"
sleep 1
JOBS=$(docker-compose exec cli python cli.py list-jobs)
check "Fail to get the list of jobs"

step "Check list of jobs (id_job = $ID_JOB)"
if [[ ${JOBS[@]} != *"{'id': ${ID_JOB},"* ]]; then
    echo "${JOBS[@]}"
    error "The list of jobs doesn't contain the new job"
fi

#--
step "Wait some seconds and get logs of the job (id_job = $ID_JOB)"
sleep 14
LOGS=$(docker-compose exec cli python cli.py get-job-logs $ID_JOB)
check "Fail to get the logs"

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

step "The Topology Test is successful"