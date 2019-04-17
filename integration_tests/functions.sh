GREEN="\e[32m"
NORMAL="\e[39m"
RED="\e[31m"
BLUE="\e[34m"

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