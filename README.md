

# Ambiente Apache Spark com Docker

Configurando um ambiente Apache Spark utilizando Docker, ideal para desenvolvimento, testes e aprendizado. Ele consiste em múltiplos containers para simular um cluster funcional.

## Estrutura do Projeto

O ambiente Spark é composto pelos seguintes containers:

1. **Master Node**
   - Responsável por gerenciar o cluster e coordenar a execução das tarefas.  
   - **Portas expostas**:
     - `7077`: Porta do protocolo Spark.
     - `8080`: Web UI do Master para monitoramento.
2. **Worker Nodes** (2 containers)
   - Executam as tarefas distribuídas e gerenciam dados em memória/disco.  
   - Comunicados ao Master Node através da porta `7077`.
3. **Client Node**
   - Ambiente separado para submeter jobs ao cluster e executar consultas.  
   - Inclui ferramentas como `pyspark` ou `spark-submit`.
4. **Armazenamento Compartilhado**
   - Simulando sistemas distribuídos como HDFS, será usado volumes do Docker diretamente sem um container dedicado.

## Tecnologias Utilizadas

- [Apache Spark](https://spark.apache.org/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Requisitos

- Docker instalado no sistema.
- Docker Compose para orquestração dos containers.

## Desenvolvimento

### 1. Configuração de rede

O Spark é uma ferramenta distribuída que depende de uma comunicação entre os nós (master, workers e client). No Docker, é necessário configurar redes personalizadas.para garantir que os containers possam se comunicar corretamente.
<br><br>
Criando uma rede bridge personalizada chamada `spark-network`. A rede bridge Funciona como uma sub-rede privada interna, isolando containers, mas permitindo que se comuniquem entre si. Essa rede é a mais comum para containers em ambientes isolados.

```yml
networks:
  spark-network:
    driver: bridge
```

### 2. Configuração dos Nós Spark

Nesta etapa, foram criados e configurados três arquivos principais para garantir que o Apache Spark funcione de maneira eficiente no ambiente distribuído: **`spark-env.sh`**, **`spark-defaults.conf`**, e **`docker-compose.yml`**.

#### spark-env.sh

O arquivo **`spark-env.sh`** é responsável pela configuração de variáveis de ambiente que são usadas pelo Apache Spark durante a execução.

```bash
# Variáveis de ambiente comuns (master e worker)
SPARK_HOME=/opt/bitnami/spark        # Diretório raiz da instalação do Apache Spark
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64  # Caminho do JDK necessário para o Spark
HADOOP_CONF_DIR=/opt/hadoop/conf     # Diretório de configuração do Hadoop (usado se integrar com HDFS)
SPARK_CONF_DIR=/opt/spark/conf       # Diretório onde as configurações do Spark estão armazenadas

# Configuração específica para o Master
SPARK_MASTER_HOST=spark-master       # Nome do host do nó Master no cluster Spark
SPARK_MASTER_PORT=7077               # Porta onde o Master recebe conexões RPC
SPARK_MASTER_WEBUI_PORT=8080         # Porta para acessar a interface Web do Master

# Configuração específica para os Workers
SPARK_WORKER_CORES=2                 # Número de núcleos alocados por cada nó Worker
SPARK_WORKER_MEMORY=1g               # Memória total disponível para cada Worker (2 GB)
SPARK_WORKER_PORT=8888               # Porta onde o Worker recebe conexões RPC
SPARK_WORKER_WEBUI_PORT=8081         # Porta para acessar a interface Web de cada Worker
```

#### spark-defaults.conf

O arquivo **`spark-defaults.conf`** contém as configurações padrão do Apache Spark, como parâmetros de configuração relacionados à performance, a integração com outros sistemas (como Hadoop), e opções de configuração para a execução de jobs.

```bash
# Configuração de logs
## Ativa o registro de eventos do Spark para monitorar jobs
spark.eventLog.enabled true

## Diretório onde os eventos do Spark serão armazenados
spark.eventLog.dir file:/tmp/spark-events

# Configuração do Master
## Define o endereço do Master no cluster, incluindo o protocolo (spark://)
spark.master spark://spark-master:7077

# Configuração de jobs
## Quantidade de memória alocada para o driver (512 MB neste caso)
spark.driver.memory 512m

## Quantidade de memória alocada para cada executor no cluster (512 MB neste caso)
spark.executor.memory 512m

## Número de núcleos de CPU alocados para cada executor
spark.executor.cores 2
```

#### docker-compose.yml

O arquivo **`docker-compose.yml`** é responsável por definir e configurar os serviços (containers) necessários para a execução do Apache Spark em um ambiente Dockerizado. Ele define os serviços principais do cluster, como o Spark Master e os Spark Workers, além de suas dependências e redes.

```yml
version: '3'  # Versão do Docker Compose

services:  # Definindo os serviços (containers) que serão utilizados

  spark-master:  # Serviço do Master
    image: bitnami/spark:latest  # Imagem Docker do Apache Spark
    container_name: spark-master  # Nome do container
    hostname: spark-master  # Nome do host do container
    networks:
      - spark-network  # Conectando o container à rede 'spark-network'
    ports:
      - "7077:7077"  # Porta RPC (usada para comunicação com os Workers)
      - "8080:8080"  # Porta WebUI (interface de monitoramento do Master)
    command: ["/opt/bitnami/spark/bin/spark-class", "org.apache.spark.deploy.master.Master", "--host", "spark-master", "--port", "7077", "--webui-port", "8080"]
    # Comando para iniciar o Master do Spark, definindo o host, porta RPC e a porta da WebUI

  spark-worker-1:  # Serviço do primeiro Worker
    image: bitnami/spark:latest  # Imagem Docker do Apache Spark
    container_name: spark-worker-1  # Nome do container
    hostname: spark-worker-1  # Nome do host do container
    networks:
      - spark-network  # Conectando o container à rede 'spark-network'
    depends_on:
      - spark-master  # O worker depende que o master esteja rodando
    command: ["/opt/bitnami/spark/bin/spark-class", "org.apache.spark.deploy.worker.Worker", "spark://spark-master:7077"]
    # Comando para iniciar o Worker do Spark e conectar ao master via RPC (porta 7077)

  spark-worker-2:  # Serviço do segundo Worker
    image: bitnami/spark:latest  # Imagem Docker do Apache Spark
    container_name: spark-worker-2  # Nome do container
    hostname: spark-worker-2  # Nome do host do container
    networks:
      - spark-network  # Conectando o container à rede 'spark-network'
    depends_on:
      - spark-master  # O worker depende que o master esteja rodando
    command: ["/opt/bitnami/spark/bin/spark-class", "org.apache.spark.deploy.worker.Worker", "spark://spark-master:7077"]
    # Comando para iniciar o Worker do Spark e conectar ao master via RPC (porta 7077)

networks:  # Definindo a rede que os containers irão usar
  spark-network:  # Rede personalizada para os containers
    driver: bridge  # Usando o driver de rede 'bridge' para comunicação entre containers
```

Ao iniciar os serviços via Docker Compose utilizando `docker-compose up`, A UI do Spark Master é iniciado corretamente.
<img src="_images/200.png"></img>
**Workers Ativos**<br>
- Há 2 Workers registrados, ambos no estado ALIVE.
- Cada Worker possui 12 núcleos (Cores) disponíveis, totalizando 24 núcleos no cluster.
- A memória alocada para cada Worker é de 6.4 GiB, somando 12.9 GiB no cluster.

**Aplicações e Drivers**<br>

- Não há aplicações em execução no momento (Running Applications: 0).
- Não há drivers conectados ao Master no momento.

Status Geral: O Master e os Workers estão corretamente configurados, prontos para executar tarefas distribuídas no cluster.

**REPARE QUE AS CONFIGURAÇÕES DE MEMÓRIA ALOCADAS NÃO FORAM APLICADAS PORQUE NÃO CONFIGURAMOS OS VOLUMES PARA RECEBER NOSSAS CONFIGURAÇÕES DO `spark-env.sh`. FAREMOS NA PRÓXIMA ETAPA.**

### 3. Gerenciamento de Volume e Armazenamento Compartilhado

Foi implementado o conceito de volumes Docker para gerenciar e compartilhar os arquivos de configuração entre os containers.

#### Definição do volume

O volume foi definido na seção volumes do arquivo `docker-compose.yml`, com o nome spark-volume.

```yml
volumes:  # Definindo o volume compartilhado que os containers irão usar
  spark-volume:
    driver: local  # Define um volume local
```

#### Montagem do Volume nos Containers

O volume spark-volume foi anexado a três containers no arquivo docker-compose.yml: spark-master, spark-worker-1 e spark-worker-2. Isso foi configurado para que todos compartilhem o diretório /opt/bitnami/spark/conf.
```yml
# Exemplo de configuração do volume em cada container
volumes:
  - spark-volume:/opt/bitnami/spark/conf
```

### 4. Distribuição de Carga entre Workers

#### Transferência de Arquivos de Configuração para o Volume
Os arquivos de configuração do Spark foram movidos para o volume spark-volume para que os containers utilizem configurações centralizadas.
```bash
sudo su
sudo cp "/mnt/c/Users/Vinicius Luiz/Desktop/Ambiente-Spark-Docker/spark-env.sh" /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data
sudo chmod 644 /var/lib/docker/volumes/ambiente-spark-docker_spark-volume/_data/spark-env.sh
```

Após aplicar as configurações do nosso `spark-env.sh`. Obtivemos as seguintes mudanças de configuração.
<img src="_images/300.png"></img>

| **Parâmetro**          | **Antes**                | **Agora**               |
|------------------------|--------------------------|-------------------------|
| **Cores in Use**       | 24 (12 por worker)       | 4 (2 por worker)        |
| **Memory in Use**      | 12.9 GiB (6.4 GiB/worker)| 2.0 GiB (1.0 GiB/worker)|

### 5. Integração com um Ambiente de Client

#### Por que ter um Client é importante?
O client é responsável para a interação com o cluster e para o desenvolvimento ágil. Ele centraliza funções de configuração, envio e monitoramento de jobs. Sem ele, o cluster Spark seria apenas um ambiente passivo, aguardando comandos externos sem oferecer suporte completo ao ciclo de desenvolvimento.

```yml
  spark-client:  # Novo serviço do Client
    image: bitnami/spark:latest  # Imagem Docker do Apache Spark
    container_name: spark-client  # Nome do container
    hostname: spark-client  # Nome do host do container
    networks:
      - spark-network  # Conectando o container à rede 'spark-network'
    depends_on:
      - spark-master  # O client depende que o master esteja rodando
    volumes:
      - spark-volume:/opt/bitnami/spark/conf  # Monta o mesmo volume compartilhado
    entrypoint: ["/bin/bash"]  # Inicia o container em modo interativo
    # O client será acessado manualmente para submeter jobs
```


### 6. Resiliência e Escalabilidade

Um cluster Spark real precisa lidar com falhas e mudanças na demanda.

- **Desafio:** Criar um ambiente que permita a escalabilidade horizontal (adicionar/remover workers) sem reconfiguração manual excessiva.
- **Dica:** Use variáveis de ambiente e um Docker Compose dinâmico para permitir que novos workers sejam adicionados rapidamente.

### 7. Observabilidade e Monitoramento

Monitorar o estado do cluster e os jobs é essencial.

- **Desafio:** Implementar ferramentas para monitorar o Spark, como a interface de usuário nativa do Spark e logs dos containers.
- **Dica:** Redirecione logs para volumes ou sistemas como Elastic Stack, Prometheus ou Grafana.

# Arquitetura Lógica vs Arquitetura Física

As duas nomenclaturas para a arquitetura do Spark possuem algumas correlações, mas não são exatamente equivalentes. Vou explicar a relação entre os termos:

| **Componente**      | **Nomenclatura 1 (Arquitetura Lógica)**      | **Nomenclatura 2 (Arquitetura Física)** | **Descrição**                                                |
| ------------------- | -------------------------------------------- | --------------------------------------- | ------------------------------------------------------------ |
| **Driver**          | Spark Application/Spark Driver/Spark Session | Client Node                             | O processo principal que coordena a execução da aplicação. Pode estar no Client Node (modo client) ou em um nó do cluster (modo cluster). |
| **Cluster Manager** | Cluster Manager                              | Master Node                             | Gerencia os recursos do cluster e distribui tarefas para os nós de trabalho (Worker Nodes). |
| **Executor**        | Spark Executor                               | Worker Node                             | Processos que executam as tarefas atribuídas pelo Cluster Manager em nós físicos. |

### Diferenças principais destacadas:
| **Aspecto**         | **Nomenclatura 1**                                    | **Nomenclatura 2**                                           |
| ------------------- | ----------------------------------------------------- | ------------------------------------------------------------ |
| **Foco**            | Componentes lógicos do Spark                          | Arquitetura física do cluster                                |
| **Driver**          | Sempre chamado de "Driver"                            | Refere-se ao nó físico onde o Driver é executado (Client Node no modo client ou um nó do cluster no modo cluster). |
| **Cluster Manager** | Componente lógico que gerencia os recursos do cluster | Localizado no Master Node                                    |
| **Executors**       | Processos Spark responsáveis pela execução de tarefas | Localizados nos Worker Nodes                                 |

Se você está planejando usar Docker para criar um ambiente Spark, considerar os dois pontos de vista será útil: os **componentes lógicos** para configurar o Spark corretamente e os **nós físicos** para entender como distribuir os contêineres.
