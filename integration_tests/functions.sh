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
