#!/bin/bash
DIR="${BASH_SOURCE%/*}"
source "$DIR/functions.sh"

# Launch in the main directory of splay :
# bash integration_tests/all_tests.sh

big_step "Clean, Rebuild and Run docker images"
bash $DIR/build_run.sh

big_step "Run the basic test"
bash $DIR/basic_test.sh

big_step "Run the network test"
bash $DIR/network_test.sh

big_step "Run the topology test"
bash $DIR/topo_test.sh

big_step "Run the crash point test"
bash $DIR/crash_point_test.sh

big_step "Run the raft test"
bash $DIR/raft_test.sh

# If you want to clean all docker of splay uncomment the next line
# bash clean-all-dockers.sh