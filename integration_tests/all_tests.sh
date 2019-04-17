#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

big_step "Clean, Rebuild and Run docker images"
bash $DIR/build_run.sh

big_step "Run the basic test"
bash $DIR/basic_test.sh

big_step "Run the network test"
bash $DIR/network_test.sh

big_step "Run the topology test"
bash $DIR/network_test.sh


