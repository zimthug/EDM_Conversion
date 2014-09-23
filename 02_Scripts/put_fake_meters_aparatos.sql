insert into aparatos
  select 'TML' usuario, trunc(sysdate) f_actual, 'TEST_MTRS' programa,
         'A7' || lpad(rownum, 6, 0) num_apa, 'MC010' co_marca,
         'ML031' co_modelo, tip_apa, 'CM116' est_apa, 3602 cod_almacen,
         co_prop_apa, f_fabric, f_prox_calibracion, f_prox_verificacion,
         num_lote, lugar, observaciones, 0 nis_rad, 0 nif_apa, sec_pm,
         num_precin, error, co_condition, defect, co_fabric, lect, num_os,
         cod_emp, num_order, num_tender, cod_agent, f_guarantee, num_msr,
         usage_purpose, ii_result, num_license, num_bill, num_test,
         num_apa_mf
    from aparatos
   where tip_apa = 'TA100'
     and rownum <= 23;

insert into haparatos
select usuario, f_actual, programa, num_apa, co_marca, trunc(sysdate) f_cambio, est_apa,
       cod_almacen, num_lote, nis_rad, nif_apa, sec_pm, num_precin, tip_apa,
       co_modelo, error, co_condition, defect, lect, num_os, cod_emp
  from aparatos where programa = 'TEST_MTRS';
