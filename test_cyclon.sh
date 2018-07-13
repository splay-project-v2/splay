#!/usr/bin/env bash
./rebuild.sh
docker run -it splay_cli_client /bin/bash -c "./splay-start-session.lua; sleep 1s; ./splay-submit-job.lua -n 5 app/cyclon.lua"
