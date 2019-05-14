GREEN="\e[32m"
NORMAL="\e[39m"
RED="\e[31m"
BLUE="\e[34m"

shopt -s expand_aliases # Let non-interactive shell use aliases

if [[ "$OSTYPE" == "darwin"* ]]
then
  alias grep="ggrep"
fi

function big_step () {
    echo -e ">>>> $BLUE$1$NORMAL <<<<"
}

function step () {
    echo -e ">> $GREEN$1$NORMAL <<"
}

function error () {
    echo -e ">>> $RED$*$NORMAL"
    exit 1
}

function check () {
    if [ $? != 0 ]; then
        error $*
    fi
}

function submit () {
    local JOB=$1
    local TOPO=$2
    if [ ! -z "$TOPO" ]; then
        step "Submit a job ${JOB} with ${TOPO}"
        JOB_RES=$(docker-compose exec cli python cli.py submit-job -n "${JOB}" -s 2 ${JOB} -t ${TOPO})
        check "Fail to submit the job" "\n" "${JOB_RES[@]}"
    else 
        step "Submit a job ${JOB} with ${TOPO}"
        JOB_RES=$(docker-compose exec cli python cli.py submit-job -n "${JOB}" -s 2 ${JOB})
        check "Fail to submit the job" "\n" "${JOB_RES[@]}"
    fi

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
}

function kill_job () {
    step "Kill a job"
    KILL=$(docker-compose exec cli python cli.py kill-job ${ID_JOB})
    check "Kill job fails : ${KILL}"
}

function get_logs () {
    #--
    step "Wait $1 seconds and get logs of the job (id_job = $ID_JOB)"
    sleep $1
    LOGS=$(docker-compose exec cli python cli.py get-job-logs $ID_JOB)
    check "Fail to get the logs : $LOGS"
}
