# Covid Data Engineering Project
O seguinte Repositório trata-se de um projeto de engenheria de dados incentivado pelo [Semantix](https://www.semantix.ai/) como parte opcional do curso [Big Data Engineer](https://www.semantix.ai/academy). A estrutura dela está definida na seguinte imagem:

<img width="2608" alt="strucuture" src="https://user-images.githubusercontent.com/42154494/164946866-a612778a-59c8-4512-98ca-ba506a8364d6.png">

Os dados usados como entrada dos dados estão disponíveis no seguinte link [CORONAVÍRUS - BRASIL](https://covid.saude.gov.br/) e é em cima desses dados que todo o projeto está sendo feito.
## Etapas do Projeto

1. Enviar os dados para o hdfs
2. Otimizar todos os dados do hdfs para uma tabela Hive particionada por município.
3. Criar as 3 vizualizações pelo Spark com os dados enviados para o HDFS:
- Casos recuperados
- Casos em acompanhamento
- Casos confirmados
    - Acumulado
    - Casos novos
    - Incidência
- Óbitos confirmados
    - Óbitos acumulados
    - Casos novos
    - Letalidade %
    - Mortalidade
4. Salvar a primeira visualização como tabela Hive
5. Salvar a segunda visualização com formato parquet e compressão snappy
6. Salvar a terceira visualização em um tópico no Kafka
7. Criar a visualização pelo Spark com os dados enviados para o HDFS
- Síntese de casos, óbitos, incidência e mortalidade
    - Brasil 
        - Subregiões
            - Estados
8. Salvar a visualização do exercício 6 em um tópico no Elastic
9. Criar um dashboard no Elastic para visualização dos novos dados enviados

## Desenvolvimento
### HDFS / Hive
A primeira parte do projeto se descreve basicamente em enviar os dados do container do namenode para o HDFS e uma vez que os dados estão no HDFS, devo inserí-los em uma tabela hive. A parte de enviar os dados para o HDFS foi bem tranquila visto que não havia muito segredo nisso, apenas os comandos comuns do HDFS como:

`hdfs dfs -mkdir <pasta>` Para criar a estrutura de pastas

`hdfs dfs -put <arquivo_local> <pasta_no_hdfs>` para enviar os dados para o HDFS de fato

`hdfs dfs -ls <pasta>` Para verificar se os arquivos foram inseridos corretamente.

Uma vez no HDFS, foi a vez de acessar o Hive. O cliente usado para acessar o hive foi o Beeline. E nessa parte, a tarefa principal foi realizar otimização nos arquivos que estavam no HDFS, além de particionar os dados em outras tabelas. Criar a tabela externa e buscar os dados que eu precisei também foi bem tranquilo, porém por alguma falta de atenção, o partionamento foi um pouco demorado, pois havia me esquecido que para criar uma tabela dinamicamente particionada com os dados de outra tabela, a coluna que seria particionada deveria ser a última selecionada da outra tabela. Porém, re-lendo minhas anotações consegui fazer essa parte. Outro problema também que me fez perder um tempo sem sair do lugar foi o fato de que os dados das colunas de novos recuperados e novos acompanhamento estavam vindo como nulos por algum motivo que ainda desconheço e só fui notar esse problema quando já estava trabalhando com os dados no Spark. Basicamente, na criação da tabela externa eu estava definindo os campos citados como INT, e o processaemnto desses dados estavam dando errado fazendo com que toda a coluna viesse nula. A solução foi ler dados dados como string o que tambpem me gerou um problema que o spark acusava erro nas leituras dos arquivos. Foi então que eu criei uma tabela intermediaria em que precisei realizar algumas confirgurações adicionais para que eu pudesse realizar um UPDATE na tabela. Essa parte também foi um pouco dificil, pois não sabia que era tão burocrático para fazer um update no Hive. Uma vez que isso estava feito, foi a hora de processar os dados utilizando o Apache Spark

### Spark
Uma vez que os dados já estavam otimizados no Hive era a hora de processá-los usando o Spark. Escolhi o PySpark para fazer isso pois tenho mais familiaridade com a Linguagem Python. Vale a ressalva que parte foi feita com o container local do Jupyter-spark e parte foi feita usando O Databricks, por questões de processamento e de poder computacional, os jobs estavam demorando muito para serem completos localmente e muita das vezes o container morria por falta de recursos.

Aqui a dificuldade foi aplicar na prática o que eu havia aprendido nas aulas, pois obviamente se tratando de um cenário real as informações acerca do que se pedem não tem o passo-a-passo de como fazer e isso foi bom pois descobri melhor como funciona o processamento de dados. Aprendi que para realizar cálculos com uma coluna (como foi o caso da letalidade, incidencia e mortalidade) eu deveria usar a função `withColumn` e não tentar fazer esse cálculo diretamente na agregação. Usei tambem um atributo que não estava habituado a usar que é a função `last` do sql para pegar o último dado de uma coluna (antes eu estava tentando agregar os dados e dividir pela quantidade de colunas). Uma vez que eu tinha feito a view de casos confirmados, as outras foram bem mais fáceis.

![image](https://user-images.githubusercontent.com/42154494/164984626-1e0d1595-e330-482c-810c-90277f881d85.png)

Uma vez processados os dados era necessário realizar o carregamento desses dados tanto no Hive, quanto no Kafka e no ElasticSearch. Aqui foi a parte mais complicada desse projeto pois eu estava usando tanto o kafka quanto o Elasticsearch em cloud, então havia mais configurações do que o aprendido. A tentiva de conectar ao Kafka em cloud foi falha, não consegui, então essa parte subi somente o container do Kafka e do Jupyter que era necessário para salvar os dados localmente com mais facilidade.

Já no elasticsearch eu consegui conectar com ele em cloud. Foi um pouco complicado achar uma síntese de tudo que eu precisava para conectar, além de que eram dois problemas diferentes:
1. Usar uma biblioteca externa no Spark
2. Conectar com a Cloud

Para isso eu usaria o spark-submit afim de enviar um job spark usando o .jar do elasticsearch para hadoop/spark . Porém o spark-submit não reconhecia a biblioteca não importava o que eu fizesse. Porfim acabei usando o Pyspark que aceitou tranquilamente os pacotes (exatamente os mesmos pacotes que estava enviando para o spark-submit). Uma vez que consegui usar a biblioteca externa era hora de descobri quais options para isso houve um tutorial que me ajudou bastante nisso: [Spark ElasticSearch Hadoop Update and Upsert Example and Explanation](https://www.bmc.com/blogs/spark-elasticsearch-hadoop/)

```
{
    'es.nodes': ES_NODES,
    'es.port': ES_PORT,
    'es.net.http.auth.user': ES_NET_HTTP_AUTH_USER,
    'es.net.http.auth.pass': ES_NET_HTTP_AUTH_PASS,
    'es.net.sll': ES_NET_SLL,
    'es.nodes.wan.only': ES_NODE_WAN_ONLY,
    'es.write.operation': ES_WRITE_OPERATION
}
```
Então essa parte foi concluída usando o Pyspark, embora os códigos estejam no notebook.

#### Spark Submit
Minha vontade principal era usar o spark-submit, porém no final das contas foi muito mais complicada do que eu imaginava. Eu estava tentando usar uma biblioteca externa chamada `python-dotenv` para pegar as credencias do elastic do arquivo `.env` porém o spark é um tanto quanto complicado para usar isso, além de que eu também não estava conseguindo usar a biblioteca externa do elasticsearch. Até fiz um script de deploy para não ter que subir o spark-submit manualmente toda vez, porém o fato de o spark não estar aceitando as bibliotecas e não estar usando um pacote externo fez que com eu deixasse essa ideia de lado por hora (pretendo fazer isso em breve).

### Conclusão do desenvolvimento
Sendo assim, o projeto foi concluído como proposto, porém há pontos de melhora que desejo atualizar:
- fazer um spark-application que execute toda parte de processamento de ponta-a-ponta usando todas bibliotecas necessárias e integrando com os serviços que atualmente estão rodando em cloud.

## Estrutura do Projeto

```
covid_analysis
|   README.md
|   main.py
|   projeto_fina_spark.pdf
|   .gitignore
+---src
|   +---hive
|   |   +---database
|   |   |   |   1_import_data.sql
|   |   |   |   2_optimize_data.sql
|   |   |   |   3_separated_data.sql
|   +---spark
|   |   +---notebooks
|   |   |   |   covid_analysis.ipynb
+---scripts
|   |   repair.sh
|   |   setup.sh
+---docker
|   |   docker-compose-full.yml
|   |   docker-compose.yml
|   +---data
|   |   +--- pastas de configurações e dados dos containers
|   +---input
|   |   +--- pasta de volumes do docker para compartilhar dados com os containers
+---data
|   |   arquivos .csv com os dados necessários
```
## Como Rodar o Projeto ?
Para rodar esse projeto há dois pré-requisitos principais:
- Docker e Docker-compose instalados -> Instalação [Install Docker Engine](https://docs.docker.com/engine/install/)
- Python 3 -> Instalação [Download Python](https://www.python.org/downloads/)
Além disso, os scripts que fiz para rodar o projeto mais facilmente estão em shellscript então pode ser que ele não rode no Windows (você pode usar WSL nesse caso)

Uma vez que tens ambos programas instalados, basta clonar o projeto na sua pasta localmente e rodar o arquivo `main.py` é através dele que você pode administrar os serviços do projeto como subir os containers, enviar os dados, reparar os dados no HDFS. Ele funciona com o envio de parâmetros, que rodando ele passando o argumento `--help` ou sem passar nada também, ele mostra a seguinte mensagem:

![image](https://user-images.githubusercontent.com/42154494/164985560-38d34281-f7a6-4d1b-ab12-f68e418d16c6.png)

Explicação detalhada
| Comando  | O que ele faz |
|---------|---|
| --start | O primeiro comando que deve ser rodado com o Python. Ele Inicia os containers do docker necessários para o projeto. Caso você não tenha instalado as imagens dos containers, ele vai instalar automaticamente, então essa parte é ligeiramente demorada |
| --stop  | Uma vez que os containers estão executando e você queira parar esse projeto ele para os containers do docker que estão ativos (Apenas o desse projeto)  |
| --setup | Vai enviar os arquivos de dados de covid do governo o containre do docker e em seguida para o HDFS na pasta `/user/root/data` |
| --repair | Vai refazer a estrutura de pastas no HDFS e re-enviar os arquivos para o mesmo |
| --build  | Com esse comando você pode iniciar containers específicos do projeto como somente o elasticsearch, somente o jupyter spark ou vários deles |

Então para subir o projeto de fato basta rodar os seguintes comandos:
1. `python3 main.py --start`
2. `python3 main.py --setup`

Depois disso você já tem o necessário para fazer os procedimentos. Mas antes disso, alguns comandos que vão ser úteis no projeto:
|Comando|Utilidade|Documentação|
|---|---|---|
| `docker exec -it <nome_do_container> bash` | Para acessar o container do serviço | [docker exec](https://docs.docker.com/engine/reference/commandline/exec/) |
| `beeline -u 'jdbc:hive2://localhost:10000'` | Para acessar o cliente do Hive (através do container `hive-server`) | [HiverServer2 Clients](https://cwiki.apache.org/confluence/display/hive/hiveserver2+clients#HiveServer2Clients-Beeline%E2%80%93CommandLineShell) |
| `hdfs dfs -<comandos> <pasta>` | comandos semelhante aos do linux, porém usado no HDFS | [Apache Hadoop 3.3.2 Overview](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/FileSystemShell.html) |
| `kafka-console-consumer --bootstrap-server localhost:9092 --topic <topico> --from-beginning` | Verificar as mensagens em um tópico kafka | [Apache Kafka](https://kafka.apache.org/quickstart) |
| `curl <username>:<senha> GET <endpoint_elastic>/<index>/_search` | Visualizar os documentos de um índice no elasticsearch | [Search you Data Elasticsearch Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html) |

Assim você pode seguir os seguintes passos:
1. Entrar no container do Hive, executar os comandos que estão em `src/hive/database` dentro do cliente hive
2. Acessar o jupyter-spark através de localhost:8889 e fazer o upload do arquivo `src/spark/notebooks/covid_analysis.ipynb` em um notebook. (Partes que envolvem bibliotecas externas devem ser feitas, usando de preferencia o Pyspark)
    - pyspark --packages org.elasticseach:<o pacote do elastic para versão dos seus serviços> [Download](https://www.elastic.co/pt/downloads/hadoop)
4. Acessar o Kafka e visualizar o topíc
5. Acessar buscar documentos no índice do elastic correspondente.

## Considerações Finais

Qualquer coisa pode me chamar :)
