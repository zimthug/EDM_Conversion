insert into prep_messages
SELECT 'TML', trunc(sysdate), 'MANUAL', prep_msg_id.nextval, 1, trunc(sysdate), nis_rad, sec_nis,  'MS001', 1, 'load_arrears_debt',
  'msg_counter='|| prep_msg_id.currval|| '1'|| '&'|| 'msg_timestamp='|| TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')|| '&'||
               'agr_ref_no='|| nis_rad|| '-'|| LPAD (sec_nis, 2, 0)|| '&'|| 'debt_balance='|| ROUND ( (imp_tot_rec - imp_cta), 2)|| '&'|| 
               'debt_start_date='|| TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')|| '&'|| 'debt_percentage='|| decode(tip_rec, 'TR110', 50, 75)/*p.valor1*/|| '&'||
               'debt_category_id='|| REGEXP_SUBSTR (g.codigo, '[^|]+', 1, 2)|| '&'|| 'debt_ref='|| sec_rec|| nis_rad|| LPAD (sec_nis, 2, 0)|| TO_CHAR (f_fact, 'yyyymmdd')|| '&'||
               'debt_process=LOAD' p_args, 'PENDING PROCESSING'
  FROM recibos r
       INNER JOIN parametros p 
          ON parametro = 'PP_DEBT_COLL_IND'
             AND TO_CHAR (SYSDATE, 'YYYYMMDD') BETWEEN TO_CHAR (f_val_param, 'YYYYMMDD')
                                                   AND TO_CHAR (f_anul_param, 'YYYYMMDD')
       INNER JOIN prep_bill_map b ON b.bill_ref = r.tip_rec
       INNER JOIN grupos_rel g ON g.cod_grupo = 'PCD01' AND g.codigo LIKE b.prep_conc|| '%'
WHERE    --sec_rec|| nis_rad|| LPAD (sec_nis, 2, 0)|| TO_CHAR (f_fact, 'yyyymmdd') = '02900161990120140825';
 r.programa = 'PREP_DIVIDA';
 
 --select * from prep_messages
 
 
insert into prep_debt 
select 'TML', trunc(sysdate), 'MANUAL', nis_rad, sec_nis, tip_rec, sec_rec|| nis_rad|| LPAD (sec_nis, 2, 0)|| TO_CHAR (f_fact, 'yyyymmdd'),
       decode(tip_rec, 'TR110', 50, 75), 'SD001'
  from recibos
 where programa = 'PREP_DIVIDA';
