# Variáveis de ambiente comuns (master e worker)
SPARK_HOME=/opt/bitnami/spark        # Diretório raiz da instalação do Apache Spark
# JAVA_HOME=/opt/bitnami/java/bin/java  # Caminho do JDK necessário para o Spark (COMENTADO PORQUE NÃO É OBRIGATÓRIO)
HADOOP_CONF_DIR=/opt/hadoop/conf     # Diretório de configuração do Hadoop (usado se integrar com HDFS)
SPARK_CONF_DIR=/opt/spark/conf       # Diretório onde as configurações do Spark estão armazenadas

# Configuração específica para o Master
SPARK_MASTER_HOST=spark-master       # Nome do host do nó Master no cluster Spark
SPARK_MASTER_PORT=7077               # Porta onde o Master recebe conexões RPC
SPARK_MASTER_WEBUI_PORT=8080         # Porta para acessar a interface Web do Master

# Configuração específica para os Workers
SPARK_WORKER_CORES=2                 # Número de núcleos alocados por cada nó Worker
SPARK_WORKER_MEMORY=1g               # Memória total disponível para cada Worker (1 GB) (Usado no modo de deploy Standalone)
SPARK_EXECUTOR_MEMORY=1g             # Memória total disponível para cada Worker (1 GB) (Usado no modo de deploy YARN)
SPARK_WORKER_PORT=8888               # Porta onde o Worker recebe conexões RPC
SPARK_WORKER_WEBUI_PORT=8081         # Porta para acessar a interface Web de cada Worker