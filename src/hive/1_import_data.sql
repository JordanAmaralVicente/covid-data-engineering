-- Import data from hdfs to an external table
CREATE DATABASE IF NOT EXISTS covid;

USE covid;

CREATE EXTERNAL TABLE IF NOT EXISTS e_casos_covid(
    regiao STRING,
    uf CHAR(2),
    municipio STRING,
    cod_uf TINYINT,
    cod_mun INT,
    cod_regiao_saude INT,
    nome_regiao_saude STRING,
    data DATE,
    semana_epi TINYINT,
    populacao INT,
    casos_acumulado INT,
    casos_novos INT,
    obitos_acumulado INT,
    obitos_novos INT,
    recuperados_novos STRING,
    acompanhamento_novos STRING,
    interior_metropolitana INT
)
COMMENT 'External Table With Covid Numbers'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ';' 
STORED AS TEXTFILE 
LOCATION '/user/root/data/'
tblproperties('skip.header.line.count'='1');

DESC e_casos_covid;
