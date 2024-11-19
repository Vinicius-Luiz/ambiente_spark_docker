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

## Próximos Passos

1. Definir o arquivo `docker-compose.yml` para orquestrar os containers.
2. Configurar os arquivos necessários para inicializar o Master e os Workers.
3. Criar volumes para armazenamento compartilhado.
