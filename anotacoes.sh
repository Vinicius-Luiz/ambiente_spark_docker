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

sudo cp "/mnt/c/Users/Vinicius Luiz/Desktop/Ambiente-Spark-Docker/spark-env.sh" /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data
sudo chmod 644 /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data/spark-env.sh


# Mover script python para volume e executar no client
sudo su

sudo cp "/mnt/c/Users/Vinicius Luiz/Desktop/Ambiente-Spark-Docker/scripts-py/index_001.py" /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data/scripts-py
docker exec spark-client /opt/bitnami/spark/bin/spark-submit /opt/bitnami/spark/conf/scripts-py/index_001.py

# Executar um job no master
mkdir -p /opt/bitnami/spark/tmp # Crie o diretório e o arquivo de senha esperado (resolver isso depois)
touch /opt/bitnami/spark/tmp/nss_passwd

spark-submit \
  --master spark://spark-master:7077 \
  --conf spark.driver.extraJavaOptions="$SPARK_DRIVER_EXTRA_OPTS" \
  /opt/bitnami/spark/conf/scripts-py/index_001.py