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

## Desafios

### 1. Configuração de rede

O Spark é uma ferramenta distribuída que depende de uma comunicação eficiente entre os nós (master, workers e client). No Docker, você precisará configurar redes personalizadas para garantir que os containers possam se comunicar corretamente.

- **Desafio:** Configurar a comunicação entre os nós enquanto evita problemas de latência ou perda de pacotes.
- **Dica:** Utilize uma rede bridge personalizada no Docker Compose e atribua nomes amigáveis aos containers para facilitar a configuração.

### 2. Configuração dos Nós Spark

Os nós do Spark têm funções específicas, e configurar corretamente o `Master` e os `Workers` será essencial para o funcionamento do cluster.

- **Desafio:** Configurar corretamente as variáveis de ambiente (ex.: `SPARK_MASTER_HOST`, `SPARK_WORKER_MEMORY`) para que os workers se conectem ao master.
- **Dica:** Use arquivos de configuração (como `spark-env.sh` e `spark-defaults.conf`) nos seus Dockerfiles para manter as configurações organizadas.

### 3. Gerenciamento de Volume e Armazenamento Compartilhado

O Spark frequentemente usa armazenamento compartilhado para logs, checkpoints ou cache. Implementar isso com volumes Docker requer atenção.

- **Desafio:** Garantir que todos os nós possam acessar um sistema de arquivos compartilhado para sincronizar dados.
- **Dica:** Utilize volumes Docker para criar armazenamento persistente ou até mesmo serviços externos, como o HDFS (Hadoop Distributed File System), para armazenamento escalável.

### 4. Distribuição de Carga entre Workers

Equilibrar o trabalho entre os workers de maneira eficiente é essencial para aproveitar os benefícios do Spark.

- **Desafio:** Configurar os workers com recursos apropriados (CPU, memória) e garantir que eles estejam alinhados com as necessidades do Spark.
- **Dica:** Planeje a quantidade de CPU e memória que cada container pode usar com as opções `--cpus` e `--memory`.

### 5. Integração com um Ambiente de Client

O nó cliente será responsável por enviar jobs ao cluster Spark.

- **Desafio:** Configurar corretamente o ambiente do nó cliente para que ele localize o Master e interaja com o cluster.
- **Dica:** Certifique-se de que o cliente tenha as bibliotecas e as configurações adequadas para executar jobs Spark.

### 6. Resiliência e Escalabilidade

Um cluster Spark real precisa lidar com falhas e mudanças na demanda.

- **Desafio:** Criar um ambiente que permita a escalabilidade horizontal (adicionar/remover workers) sem reconfiguração manual excessiva.
- **Dica:** Use variáveis de ambiente e um Docker Compose dinâmico para permitir que novos workers sejam adicionados rapidamente.

### 7. Observabilidade e Monitoramento

Monitorar o estado do cluster e os jobs é essencial.

- **Desafio:** Implementar ferramentas para monitorar o Spark, como a interface de usuário nativa do Spark e logs dos containers.
- **Dica:** Redirecione logs para volumes ou sistemas como Elastic Stack, Prometheus ou Grafana.

## Próximos Passos

1. Definir o arquivo `docker-compose.yml` para orquestrar os containers.
2. Configurar os arquivos necessários para inicializar o Master e os Workers.
3. Criar volumes para armazenamento compartilhado.

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
