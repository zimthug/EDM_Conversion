--Cancelled frauds........
declare
 cursor ix is
select aa.*, re.imp_tot_rec, re.imp_cta, re.est_act, sec_nis, sec_rec, f_fact from recibos re, (
select 200050679 nis_rad, to_date('20100830', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200051562 nis_rad, to_date('20100809', 'yyyymmdd') mes_ano, 4732.67 valor from dual union
select 200051606 nis_rad, to_date('20070327', 'yyyymmdd') mes_ano, 430.24 valor from dual union
select 200051650 nis_rad, to_date('20051117', 'yyyymmdd') mes_ano, 2581.46 valor from dual union
select 200051724 nis_rad, to_date('20051117', 'yyyymmdd') mes_ano, 2952.25 valor from dual union
select 200051905 nis_rad, to_date('20091027', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200051912 nis_rad, to_date('20090910', 'yyyymmdd') mes_ano, 4732.67 valor from dual union
select 200052124 nis_rad, to_date('20090413', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200052560 nis_rad, to_date('20091027', 'yyyymmdd') mes_ano, 3011.7 valor from dual union
select 200052700 nis_rad, to_date('20100923', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200052733 nis_rad, to_date('20090622', 'yyyymmdd') mes_ano, 1476.13 valor from dual union
select 200054786 nis_rad, to_date('20070202', 'yyyymmdd') mes_ano, 1172 valor from dual union
select 200055045 nis_rad, to_date('20100324', 'yyyymmdd') mes_ano, 4302.43 valor from dual union
select 200055069 nis_rad, to_date('20090825', 'yyyymmdd') mes_ano, 2151.21 valor from dual union
select 200056129 nis_rad, to_date('20091117', 'yyyymmdd') mes_ano, 2952.25 valor from dual union
select 200056129 nis_rad, to_date('20051118', 'yyyymmdd') mes_ano, 2952.25 valor from dual union
select 200056199 nis_rad, to_date('20100705', 'yyyymmdd') mes_ano, 3441.94 valor from dual union
select 200056868 nis_rad, to_date('20100503', 'yyyymmdd') mes_ano, 3011.7 valor from dual union
select 200058414 nis_rad, to_date('20140617', 'yyyymmdd') mes_ano, 10225 valor from dual union
select 200058621 nis_rad, to_date('20110722', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200059460 nis_rad, to_date('20091021', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200059577 nis_rad, to_date('20100316', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200060191 nis_rad, to_date('20101109', 'yyyymmdd') mes_ano, 5162.91 valor from dual union
select 200060307 nis_rad, to_date('20100720', 'yyyymmdd') mes_ano, 3872.18 valor from dual union
select 200060506 nis_rad, to_date('20090810', 'yyyymmdd') mes_ano, 5385.19 valor from dual 
) aa where aa.mes_ano = re.f_fact and aa.nis_rad = re.nis_rad and aa.valor = re.imp_tot_rec
and imp_cta = 0;
begin
  for x in ix loop
    
    update recibos
       set est_act = 'ER600', usuario = 'TML', programa = 'CANC_FACTS', f_actual = trunc(sysdate)
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and f_fact = x.f_fact
       and sec_rec = x.sec_rec;
     
    insert into est_rec
      select 'TML' usuario, trunc(sysdate) f_actual, 'CANC_FACTS' programa, sec_rec, nis_rad, sec_nis, f_fact,
             sec_est_rec + 1, 'ER600' est_rec, f_inc_est, desc_est_rec
        from est_rec
       where nis_rad = x.nis_rad
         and sec_nis = x.sec_nis
         and f_fact = x.f_fact
         and sec_rec = x.sec_rec
         and est_rec = 'ER020';
     
  end loop;
end;


---For the ones which were skipped because of payments
declare
 cursor ix is
  select aa.*, re.imp_tot_rec, re.imp_cta,  get_desc(1, 'E', re.est_act), re.sec_nis, re.sec_rec, re.f_fact
    from recibos re, (
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
  and imp_cta = 0
  and est_act != 'ER600';
begin
  for x in ix loop
    
    update recibos
       set est_act = 'ER600', usuario = 'TML', programa = 'CANC_FACTS', f_actual = trunc(sysdate)
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and f_fact = x.f_fact
       and sec_rec = x.sec_rec;
     
    insert into est_rec
      select 'TML' usuario, trunc(sysdate) f_actual, 'CANC_FACTS' programa,
             sec_rec, nis_rad, sec_nis, f_fact, sec_est_rec + 1,
             'ER600' est_rec, f_inc_est, desc_est_rec
        from est_rec
       where nis_rad = x.nis_rad
         and sec_nis = x.sec_nis
         and f_fact = x.f_fact
         and sec_rec = x.sec_rec
         and sec_est_rec = (select max(sec_est_rec)
                              from est_rec
                             where nis_rad = x.nis_rad
                               and sec_nis = x.sec_nis
                               and f_fact = x.f_fact
                               and sec_rec = x.sec_rec);
     
  end loop;
end;
/
