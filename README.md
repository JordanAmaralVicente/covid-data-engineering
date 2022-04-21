# Covid Analysis

Referência dos dados: [CORONAVÍRUS - BRASIL](https://covid.saude.gov.br/)

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

## Considerações Finais