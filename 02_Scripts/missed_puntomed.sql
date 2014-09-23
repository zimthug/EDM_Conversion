insert into puntomed
  select usuario, f_actual, programa, nif, 0 cgv_pm, 1 aol_pm,
         'AP017' acc_pm, 1 sec_pm
    from sumcon s
   where /*cod_tar in ('E04')
         and*/
   tip_suministro != 'SU900'
   and est_sum = 'EC012'
   and not exists (select 0 from puntomed p where p.nif_pm = s.nif);

insert into puntomed_param
  select usuario, f_actual, programa, nis_rad, 1 sec_apa, f_alta f_val,
         to_date(29991231, 'yyyymmdd') f_anul, nif, 1 sec_pm, tip_fase,
         tip_tension, 'MB501' tip_pm, ' ' observacion, 10 aol_apa,
         'AM000' num_id, 0 valor, 0 porc_csmo, 2 ind_estm, 0 valor1,
         0 valor2, '/0/0/' datos
    from sumcon s
   where tip_suministro != 'SU900'
     and est_sum = 'EC012'
     and not exists
   (select 0 from puntomed_param p where p.nis_rad = s.nis_rad);
