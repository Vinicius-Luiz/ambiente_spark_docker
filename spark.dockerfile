FROM bitnami/spark:latest

# Copiar arquivos de configuração para o container
# COPY spark-env.sh /opt/spark/conf/spark-env.sh
# COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY spark-env.sh /opt/bitnami/spark/conf/spark-env.sh
COPY spark-defaults.conf /opt/bitnami/spark/conf/spark-defaults.conf

# Alterar permissões

# Alterar permissões como root
USER root
# RUN chmod +x /opt/spark/conf/spark-env.sh
RUN chmod +x /opt/bitnami/spark/conf/spark-env.sh

# Retornar ao usuário padrão para maior segurança
USER 1001

# Comando padrão para iniciar o container
# CMD ["/opt/spark/bin/spark-class"]
# CMD ["/mnt/c/Spark/bin/spark-submit"]
# CMD ["/opt/bitnami/spark/bin/spark-class"]
CMD ["/opt/bitnami/spark/bin/spark-class"]

FROM bitnami/spark:latest