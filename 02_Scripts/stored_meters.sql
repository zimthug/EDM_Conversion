declare
  cursor ix is
    select * from edmaccess.stored_meters;
  lfecha_nulla date := to_date(29991231, 'yyyymmdd');
begin
  insert into apa_lotes
    (usuario, f_actual, programa, num_lote, documento, est_lote, cantidad,
     responsable, observaciones, cod_almacen_origen, cod_almacen_destinado,
     f_cambio, f_return, test_lote)
  values
    ('TML', trunc(sysdate), 'STR_MTRS',
     '3602' || to_char(sysdate, 'yyyymmdd'), ' ', 'CM116', 83, ' ',
     'From Migration', 3602, 3602, trunc(sysdate), lfecha_nulla, ' ');
  for x in ix loop
    begin
      insert into aparatos
        (usuario, f_actual, programa, num_apa, co_marca, co_modelo, tip_apa,
         est_apa, cod_almacen, co_prop_apa, f_fabric, f_prox_calibracion,
         f_prox_verificacion, num_lote, lugar, observaciones, nis_rad,
         nif_apa, sec_pm, num_precin, error, co_condition, defect, co_fabric,
         lect, num_os, cod_emp, num_order, num_tender, cod_agent,
         f_guarantee, num_msr, usage_purpose, ii_result, num_license,
         num_bill, num_test, num_apa_mf)
      values
        ('TML', trunc(sysdate), 'STR_MTRS', x.numero, x.co_marca,
         x.co_modelo, x.tip_apa, 'CM116', 3602, 'PA003', trunc(sysdate) - 60,
         lfecha_nulla, lfecha_nulla, '3602' || to_char(sysdate, 'yyyymmdd'),
         ' ', ' ', 0, 0, 1, ' ', ' ', 'AP011', 'DF000', 'FA000', 0, 0, 0,
         ' ', ' ', 'AG000', lfecha_nulla, ' ', 'MU000', ' ', ' ', ' ', ' ',
         x.numero);
    exception
      when dup_val_on_index then
        null;
    end;
  
    /*insert into haparatos
      select usuario, f_actual, programa, num_apa, co_marca, trunc(sysdate) f_cambio,
             est_apa, cod_almacen, num_lote, nis_rad, nif_apa, sec_pm,
             num_precin, tip_apa, co_modelo, error, co_condition, defect,
             lect, num_os, cod_emp
        from aparatos
       where programa = 'STR_MTRS';*/
  end loop;
end;


select * from apa_uso
