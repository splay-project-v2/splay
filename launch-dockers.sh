# Launch DB 
docker-compose kill 
echo "Launch DB Docker"
docker-compose up -d db 

# Launch Controller 
echo "Launch Controller Docker"
docker-compose up -d controller

# Get logs from Controller 
# echo "log controller in log-controller.log"
# docker-compose logs controller >> log-controller.log

# Add Daemons 
echo "Add 10 daemon"
docker-compose scale daemon=10

# Launch Web Server
echo "Launch Web_server Docker" 
docker-compose up -d web_server

# Tail on Daemons 
# docker-compose logs -f daemon

# Terminal 
docker kill terminal
docker rm terminal
docker run --network splay_default --name terminal -it splay_terminal 

#stop all containers:
# docker kill $(docker ps -q)

#remove all containers
# docker rm $(docker ps -a -q)

#remove all docker images
# docker rmi $(docker images -q)