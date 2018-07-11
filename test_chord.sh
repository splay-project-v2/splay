#!/usr/bin/env bash
./rebuild.sh
# gnome-terminal -e "docker-compose logs -f daemon" &
# gnome-terminal -e "docker-compose logs -f" &
<<<<<<< HEAD
docker run --network splay_default -it splay_terminal /bin/bash -c "./splay-start-session.lua; sleep 5s; ./splay-submit-job.lua -n 2 app/cyclon.lua"
=======
docker run --network splay_default -it splay_terminal /bin/bash -c "./splay-start-session.lua; sleep 5s; ./splay-submit-job.lua -n 1 app/cyclon.lua"
>>>>>>> 971fb621aa367f893abbe06a33b5280950c6f5ee
