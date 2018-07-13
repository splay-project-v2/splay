#!/usr/bin/env bash
./rebuild.sh
docker run  --network splay_default -it splay_terminal /bin/bash -c "./splay-start-session.lua; sleep 1s; ./splay-submit-job.lua -n 5 app/cyclon.lua"
