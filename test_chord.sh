./rebuild.sh
# gnome-terminal -e "docker-compose logs -f daemon" &
# gnome-terminal -e "docker-compose logs -f" &
docker run --network splay_default -it splay_terminal /bin/bash -c "./splay-start-session.lua; sleep 5s; ./splay-submit-job.lua -n 1 app/chord.lua"