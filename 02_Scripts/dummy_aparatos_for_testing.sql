insert into aparatos
  select usuario, f_actual, programa, 'A' || lpad(rownum, 8, 0) num_apa,
         'MC009' co_marca, co_modelo, tip_apa, 'CM116' est_apa, cod_almacen,
         co_prop_apa, f_fabric, f_prox_calibracion, f_prox_verificacion,
         '102600000234501' num_lote, lugar, observaciones, 0 nis_rad,
         0 nif_apa, sec_pm, num_precin, error, co_condition, defect,
         co_fabric, lect, num_os, cod_emp, num_order, num_tender, cod_agent,
         f_guarantee, num_msr, usage_purpose, ii_result, num_license,
         num_bill, num_test, num_apa_mf
    from aparatos
   where rownum <= 10
     and tip_apa = 'TA165';

insert into haparatos
  select usuario, f_actual, programa, num_apa, co_marca,
         trunc(sysdate) f_cambio, est_apa, cod_almacen, num_lote, nis_rad,
         nif_apa, sec_pm, num_precin, tip_apa, co_modelo, error,
         co_condition, defect, lect, num_os, cod_emp
    from aparatos a
   where est_apa = 'CM116'
     and not exists (select 0
            from haparatos
           where num_apa = a.num_apa
             and co_marca = a.co_marca);
