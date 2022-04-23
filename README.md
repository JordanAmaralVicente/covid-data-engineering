# Covid Analysis

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
