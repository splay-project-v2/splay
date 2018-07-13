#!/usr/bin/env bash
./rebuild.sh
docker run  --network splay_default -it splay_cli_client /bin/bash -c "./splay-start-session.lua; sleep 0s; ./splay-submit-job.lua -n 5 app/cyclon.lua"
