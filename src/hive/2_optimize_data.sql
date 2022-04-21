CREATE TABLE casos_covid_opt (
    regiao STRING,
    uf STRING,
    municipio STRING,
    data date,
    populacao INT,
    casos_novos INT,
    obitos_novos INT,
    recuperados_novos INT,
    acompanhamento_novos INT
) 
COMMENT 'optimized data from e_casos_covid table';

INSERT OVERWRITE TABLE casos_covid_opt 
SELECT regiao ,uf ,municipio ,data ,populacao,
casos_novos, obitos_novos, recuperados_novos,
acompanhamento_novos FROM e_casos_covid;