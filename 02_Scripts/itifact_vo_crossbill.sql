/*insert into itifact_vo
  select distinct 'CONV_EDM', trunc(sysdate), 'CONV_EDM', su.nis_rad,
                  su.sec_nis, 'FT011' tip_fact, f_trat, su.cod_unicom, ruta,
                  12 ciclo, num_itin, tip_asoc, 2 ind_anom_med,
                  2 ind_embalsado, 'IT001' est_itifact, 2 ind_anticipo,
                  2 ind_os, su.cod_mask, f_fact, 1 sec_rec, 0 cod_emp,
                  0 cod_cenlec, 1 ind_prefact, 'TR110' tip_rec,
                  201312 period, to_date(29991231, 'yyyymmdd') f_proc_min,
                  2013 year
    from apmedida_co co, fincas_per_lect fp, sumcon su
   where (co.nis_rad, co.f_fact) in
         (select nis_rad, c.dfac
            from edmgalatee.centfac c, int_supply s
           where periode = '201312'
             and c.centre = s.centre
             and c.client = s.client
             and c.ordre = s.ordre)
     and co.nis_rad = su.nis_rad
     and su.nif = fp.nif;
*/

insert into itifact_vo_apa
select 'CONV_EDM', trunc(sysdate), 'CONV_EDM', su.nis_rad, su.sec_nis, f_trat, 'FT011' tip_fact,
       num_apa, co_marca, tip_csmo, sec_lect, f_fact f_lreal, tip_lect, lect lect_act,
      2 ind_anom_med, 'AN000' co_al, 0 cod_emp, 0 time_lect
  from apmedida_co co, fincas_per_lect fp, sumcon su
 where (co.nis_rad, co.f_fact) in
       (select nis_rad, c.dfac
          from edmgalatee.centfac c, int_supply s
         where periode = '201312'
           and c.centre = s.centre
           and c.client = s.client
           and c.ordre = s.ordre)
   and co.nis_rad = su.nis_rad
   and su.nif = fp.nif;
