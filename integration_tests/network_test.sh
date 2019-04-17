#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# before execute this one execute the build_run script
# bash integration_tests/build_run.sh 

#--
step "Submit a job using network sockets"
JOB_RES=$(docker-compose exec cli python cli.py submit-job -n "TEST" -s 2 app_test/simple_net.lua)
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
sleep 10
LOGS=$(docker-compose exec cli python cli.py get-job-logs $ID_JOB)
check "Fail to get the logs"

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