docker-compose kill 
docker-compose build 
docker-compose up -d db 
sleep 2 
docker-compose up -d controller 
docker-compose logs -f controller
