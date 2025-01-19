# Monitoramento de uma rede Docker
docker network ls
docker network inspect spark-network

# Subir e derrubar docker compose
docker-compose down --volumes --rmi all
docker-compose up --build
docker-compose down && docker-compose up -d

## ou
docker-compose down  
docker-compose up -d

# Mover arquivo de configuração de spark pro volume
sudo su

sudo cp "/mnt/c/Users/Vinicius Luiz/Desktop/Ambiente-Spark-Docker/spark-env.sh" "/var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data"
sudo chmod 644 "/var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data/spark-env.sh"

# Abrir terminal do spark-client
docker exec -it spark-client /bin/bash

# Executar um job no master
spark-submit \
  --master spark://spark-master:7077 \
  --conf spark.driver.extraJavaOptions="$SPARK_DRIVER_EXTRA_OPTS" \
  /opt/bitnami/spark/conf/scripts-py/index_001.py