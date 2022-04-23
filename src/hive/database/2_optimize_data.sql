SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
SET hive.enforce.bucketing=true;
SET hive.exec.dynamic.partition.mode=nostrict;

CREATE TEMPORARY TABLE temp_opt_casos(
    regiao STRING,
    uf STRING,
    municipio STRING,
    data date,
    populacao INT,
    casos_novos INT,
    obitos_novos INT,
    recuperados_novos STRING,
    acompanhamento_novos STRING
)
CLUSTERED BY (uf) INTO 4 BUCKETS
STORED AS ORC
TBLPROPERTIES ('transactional'='true');

INSERT INTO TABLE temp_opt_casos 
SELECT regiao ,uf ,municipio ,data ,populacao,
casos_novos, obitos_novos, recuperados_novos,
acompanhamento_novos FROM e_casos_covid;

UPDATE temp_opt_casos SET recuperados_novos = '0' WHERE recuperados_novos='';
UPDATE temp_opt_casos SET acompanhamento_novos = '0' WHERE acompanhamento_novos='';
UPDATE temp_opt_casos SET municipio = NULL where municipio='';

CREATE TABLE casos_covid_opt 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/root/casos_covid_opt'
AS SELECT * FROM temp_opt_casos;