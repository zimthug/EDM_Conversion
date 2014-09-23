LOAD DATA
INFILE 'xaixai_dates_changes.csv'

INTO TABLE open_u.tmp_xaixai_dates
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'TRAILING NULLCOLS
(
NIS_RAD                                                            ,
ZONA                                                               ,
INSTALACAO                                                         ,
MES_ANO                                           DATE "DD/MM/YYYY",
DATAVALOR                                         DATE "DD/MM/YYYY",
LEITURA                                                            ,
VALOR                                                              ,
LEITURAREA                                                         ,
POTENCIA_FACTURADA                                                 
)