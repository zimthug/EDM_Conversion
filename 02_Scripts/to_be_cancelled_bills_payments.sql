select aa.*, re.imp_tot_rec, re.imp_cta,  get_desc(1, 'E', re.est_act), re.sec_nis, re.sec_rec, re.f_fact, pg.f_pago, pg.imp_pago,
       get_desc(1, 'E', pg.est_pago)
  from recibos re, pagos pg, (
select 200050557 nis_rad, to_date('20060101', 'yyyymmdd') mes_ano, 223.49 valor from dual union
select 200051112 nis_rad, to_date('20090501', 'yyyymmdd') mes_ano, 1007.95 valor from dual union
select 200051633 nis_rad, to_date('20060701', 'yyyymmdd') mes_ano, 524.23 valor from dual union
select 200051646 nis_rad, to_date('20090401', 'yyyymmdd') mes_ano, 1428.78 valor from dual union
select 200051763 nis_rad, to_date('20061201', 'yyyymmdd') mes_ano, 817.16 valor from dual union
select 200052005 nis_rad, to_date('20070501', 'yyyymmdd') mes_ano, 1109.82 valor from dual union
select 200052508 nis_rad, to_date('20061201', 'yyyymmdd') mes_ano, 299.35 valor from dual union
select 200052683 nis_rad, to_date('20071001', 'yyyymmdd') mes_ano, 87.27 valor from dual union
select 200053006 nis_rad, to_date('20070301', 'yyyymmdd') mes_ano, 390.82 valor from dual union
select 200054142 nis_rad, to_date('20091001', 'yyyymmdd') mes_ano, 1547.12 valor from dual union
select 200054527 nis_rad, to_date('20080601', 'yyyymmdd') mes_ano, 36192.23 valor from dual union
select 200054902 nis_rad, to_date('20081001', 'yyyymmdd') mes_ano, 87.27 valor from dual union
select 200055752 nis_rad, to_date('20060701', 'yyyymmdd') mes_ano, 185.08 valor from dual union
select 200056589 nis_rad, to_date('20091201', 'yyyymmdd') mes_ano, 719.35 valor from dual union
select 200058085 nis_rad, to_date('20051101', 'yyyymmdd') mes_ano, 74.84 valor from dual union
select 200058857 nis_rad, to_date('20080101', 'yyyymmdd') mes_ano, 87.27 valor from dual union
select 200058897 nis_rad, to_date('20061101', 'yyyymmdd') mes_ano, 969.49 valor from dual union
select 200059033 nis_rad, to_date('20100801', 'yyyymmdd') mes_ano, 1638.73 valor from dual union
select 200060050 nis_rad, to_date('20051001', 'yyyymmdd') mes_ano, 316.64 valor from dual union
select 200060294 nis_rad, to_date('20091001', 'yyyymmdd') mes_ano, 2132.8 valor from dual union
select 200054029 nis_rad, to_date('20060601', 'yyyymmdd') mes_ano, 404.83 valor from dual union
select 200058323 nis_rad, to_date('20061101', 'yyyymmdd') mes_ano, 1725.19 valor from dual union
select 200058703 nis_rad, to_date('20060301', 'yyyymmdd') mes_ano, 433.4 valor from dual union
select 200059090 nis_rad, to_date('20051001', 'yyyymmdd') mes_ano, 74.84 valor from dual union
select 200052942 nis_rad, to_date('20110401', 'yyyymmdd') mes_ano, 5078.59 valor from dual union
select 200053476 nis_rad, to_date('20060501', 'yyyymmdd') mes_ano, 1215.55 valor from dual union
select 200055551 nis_rad, to_date('20060601', 'yyyymmdd') mes_ano, 878.68 valor from dual union
select 200053408 nis_rad, to_date('20100501', 'yyyymmdd') mes_ano, 1219.93 valor from dual union
select 200053459 nis_rad, to_date('20070201', 'yyyymmdd') mes_ano, 3252.71 valor from dual union
select 200058532 nis_rad, to_date('20040401', 'yyyymmdd') mes_ano, 2225.52 valor from dual union
select 200060398 nis_rad, to_date('20061201', 'yyyymmdd') mes_ano, 2344.87 valor from dual union
select 200051675 nis_rad, to_date('20080201', 'yyyymmdd') mes_ano, 1425.66 valor from dual union
select 200050936 nis_rad, to_date('20090701', 'yyyymmdd') mes_ano, 1651.45 valor from dual 
) aa where aa.mes_ano = re.f_fact and aa.nis_rad = re.nis_rad and aa.valor = re.imp_tot_rec
 and  pg.nis_rad = re.nis_rad 
 and pg.sec_nis = re.sec_nis 
 and pg.sec_rec = re.sec_rec 
 and pg.f_fact = re.f_fact 
 and pg.est_pago != 'PP103'
