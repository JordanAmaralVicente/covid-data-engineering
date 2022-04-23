CREATE EXTERNAL TABLE region_part(
    uf STRING,
    municipio STRING,
    data date,
    populacao INT,
    casos_novos INT,
    obitos_novos INT,
    recuperados_novos INT,
    acompanhamento_novos INT
) PARTITIONED BY (regiao STRING);

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;


INSERT INTO TABLE region_part
partition(regiao) 
SELECT uf, municipio, data, populacao, casos_novos,
obitos_novos, recuperados_novos, acompanhamento_novos, regiao FROM casos_covid_opt
WHERE regiao != 'Brasil' AND municipio = '';

SHOW PARTITIONS region_part;

CREATE EXTERNAL TABLE cities_part (
    regiao STRING,
    uf STRING,
    data date,
    populacao INT,
    casos_novos INT,
    obitos_novos INT,
    recuperados_novos INT,
    acompanhamento_novos INT
) PARTITIONED BY (municipio STRING);

INSERT INTO TABLE cities_part
partition(municipio) 
SELECT regiao, uf, data, populacao, casos_novos,
obitos_novos, recuperados_novos, acompanhamento_novos, municipio FROM casos_covid_opt
WHERE municipio != '';

SHOW PARTITIONS cities_part;