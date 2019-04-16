GREEN="\e[32m"
NORMAL="\e[39m"
RED="\e[31m"

function step () {
    echo -e ">>> $GREEN$1$NORMAL <<<"
}

function error () {
    echo -e ">>> $RED$*$NORMAL <<<"
    exit 1
}

function checkError () {
    if [ $? != 0 ]; then
        error $*
    fi
}