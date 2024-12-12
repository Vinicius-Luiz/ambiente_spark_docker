# Monitoramento de uma rede Docker
docker network ls
docker network inspect spark-network

# Subir e derrubar docker compose
docker-compose down --volumes --rmi all
docker-compose up --build
docker-compose down && docker-compose up -d

# Mover arquivo de configuração de spark pro volume
sudo su

sudo cp "/mnt/c/Users/Vinicius Luiz/Desktop/Ambiente-Spark-Docker/spark-env.sh" /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data
sudo chmod 644 /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data/spark-env.sh