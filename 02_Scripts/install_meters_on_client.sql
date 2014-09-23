declare
  cursor lcur_main is
    select m.conv_id, m.centre, m.client, m.ordre, m.num_apa, m.co_marca,
           m.co_modelo, m.tip_apa, m.est_apa, m.rowid, m.f_inst,
           m.co_prop_apa, m.cte_apa, m.f_fabric, s.nis_rad, s.nif, s.cod_cli,
           s.f_alta, s.f_baja, s.tip_fase,
           nvl(s.tip_tension, 'TM001') tip_tension, m.f_lvto
      from int_meter m, int_supply s
     where m.centre = s.centre
       and m.client = s.client
       and m.ind_converted is null
       and s.nis_rad is not null;
  ls_tip_pm   varchar2(5);
  ls_num_id   varchar2(5);
  ls_num_lote varchar2(15) := '301300000000001';
begin

  begin
    insert into apa_lotes
      (usuario, f_actual, programa, num_lote, documento, est_lote, cantidad,
       responsable, observaciones, cod_almacen_origen, cod_almacen_destinado,
       f_cambio, f_return, test_lote)
    values
      (gls_usuario, trunc(sysdate), gls_programa, ls_num_lote, ' ', 'CM036',
       0, ' ', 'CONVERTED MTRS', 7100, 7100, trunc(sysdate), glf_fechanulla,
       ' ');
  exception
    when dup_val_on_index then
      null;
  end;

  for lcur_main_rec in lcur_main loop
  
    if lcur_main_rec.tip_apa in ('TA165', 'TA166') then
      ls_tip_pm := 'MB500';
    else
      ls_tip_pm := 'MB501';
    end if;
  
    ls_num_id := 'AM000';
  
    lcur_main_rec.f_inst := nvl(lcur_main_rec.f_inst,
                                lcur_main_rec.f_alta - 30);
  
    lcur_main_rec.f_fabric := nvl(lcur_main_rec.f_fabric,
                                  lcur_main_rec.f_alta - 30);
  
    begin
      insert into puntomed
        (usuario, f_actual, programa, nif_pm, cgv_pm, aol_pm, acc_pm,
         sec_pm)
      values
        (gls_usuario, trunc(sysdate), gls_programa, lcur_main_rec.nif, 0, 1,
         'AP017', 1);
    
      lcur_main_rec.tip_fase := nvl(lcur_main_rec.tip_fase, 'FA001');
    
      lcur_main_rec.tip_tension := nvl(lcur_main_rec.tip_tension, 'TM001');
    
      insert into puntomed_param
        (usuario, f_actual, programa, nis_rad, sec_apa, f_val, f_anul,
         nif_apa, sec_pm, tip_fase, tip_tension, tip_pm, observacion,
         aol_apa, num_id, valor, porc_csmo, ind_estm, valor1, valor2, datos)
      values
        (gls_usuario, trunc(sysdate), gls_programa, lcur_main_rec.nis_rad,
         1, lcur_main_rec.f_alta, glf_fechanulla, lcur_main_rec.nif, 1,
         lcur_main_rec.tip_fase, lcur_main_rec.tip_tension, ls_tip_pm, ' ',
         10, ls_num_id, 0, 0, 2, 0, 0, '/0/0/');
    
    exception
      when dup_val_on_index then
        null;
    end;
  
    begin
    
      if lcur_main_rec.f_lvto = glf_fechanulla then
      
        insert into aparatos
          (usuario, f_actual, programa, num_apa, co_marca, co_modelo,
           tip_apa, est_apa, cod_almacen, co_prop_apa, f_fabric,
           f_prox_calibracion, f_prox_verificacion, num_lote, lugar,
           observaciones, nis_rad, nif_apa, sec_pm, num_precin, error,
           co_condition, defect, co_fabric, lect, num_os, cod_emp, num_order,
           num_tender, cod_agent, f_guarantee, num_msr, usage_purpose,
           ii_result, num_license, num_bill, num_test, num_apa_mf)
        values
          (gls_usuario, trunc(sysdate), gls_programa, lcur_main_rec.num_apa,
           lcur_main_rec.co_marca, lcur_main_rec.co_modelo,
           lcur_main_rec.tip_apa, 'CM036', 7100, lcur_main_rec.co_prop_apa,
           lcur_main_rec.f_fabric, glf_fechanulla, glf_fechanulla,
           ls_num_lote, ' ', ' ', lcur_main_rec.nis_rad, lcur_main_rec.nif,
           1, ' ', ' ', 'AP011', 'DF000', 'FA000', 0, 0, 0, ' ', ' ',
           'AG000', glf_fechanulla, ' ', 'MU000', ' ', ' ', ' ', ' ',
           lcur_main_rec.num_apa);
      
      end if;
    
      if lcur_main_rec.f_lvto = glf_fechanulla then
      
        insert into apmedida_ap
          (usuario, f_actual, programa, nis_rad, num_apa, co_marca, est_apa,
           nif_sum, cgv_sum, nif_apa, tip_apa, co_prop_apa, aol_apa,
           amperios, tip_fase, tip_tension, coef_per, f_lvto, f_inst,
           cte_apa, f_fabric, f_urevis, ind_precin, f_precin, tip_per_lect,
           sec_pm, regulador, dimen_conex, sec_apa, frena, svorkov,
           num_precin, apa_id, f_ppm, co_accuracy, installed_by, defect)
        values
          (gls_usuario, trunc(sysdate), gls_programa, lcur_main_rec.nis_rad,
           lcur_main_rec.num_apa, lcur_main_rec.co_marca,
           lcur_main_rec.est_apa, lcur_main_rec.nif, ' ', lcur_main_rec.nif,
           lcur_main_rec.tip_apa, lcur_main_rec.co_prop_apa, 10, ls_num_id,
           lcur_main_rec.tip_fase, lcur_main_rec.tip_tension, 0,
           glf_fechanulla, lcur_main_rec.f_inst, 1, lcur_main_rec.f_fabric,
           glf_fechanulla, 2, glf_fechanulla, 'RU012', 1, ' ', 0, 1, 0, 0,
           '/0/0/', lcur_main_rec.tip_tension, glf_fechanulla, 'CY001', 1,
           'DF000');
      else
      
        insert into hapmedida_ap
          (usuario, f_actual, programa, nis_rad, num_apa, co_marca, est_apa,
           nif_sum, cgv_sum, nif_apa, tip_apa, co_prop_apa, aol_apa,
           amperios, tip_fase, tip_tension, coef_per, f_lvto, f_inst,
           cte_apa, f_fabric, f_urevis, ind_precin, f_precin, tip_per_lect,
           sec_pm, regulador, dimen_conex, sec_apa, frena, svorkov,
           num_precin, apa_id, f_ppm, co_accuracy, installed_by, defect)
        values
          (gls_usuario, trunc(sysdate), gls_programa, lcur_main_rec.nis_rad,
           lcur_main_rec.num_apa, lcur_main_rec.co_marca,
           lcur_main_rec.est_apa, lcur_main_rec.nif, ' ', lcur_main_rec.nif,
           lcur_main_rec.tip_apa, lcur_main_rec.co_prop_apa, 10, ls_num_id,
           lcur_main_rec.tip_fase, lcur_main_rec.tip_tension, 0,
           lcur_main_rec.f_lvto, lcur_main_rec.f_inst, 1,
           lcur_main_rec.f_fabric, glf_fechanulla, 2, glf_fechanulla,
           'RU012', 1, ' ', 0, 1, 0, 0, '/0/0/', lcur_main_rec.tip_tension,
           glf_fechanulla, 'CY001', 1, 'DF000');
      
      end if;
    
      update int_meter
         set ind_converted = 1
       where rowid = lcur_main_rec.rowid;
    
    exception
      when dup_val_on_index then
        dbms_output.put_line('Duplicate meter ' || lcur_main_rec.num_apa || '  ' ||
                             lcur_main_rec.co_marca);
    end;
  end loop;
  /*  HAPARATOS INSERT HERE     --- --- --- */
  insert into haparatos
    (usuario, f_actual, programa, num_apa, co_marca, f_cambio, est_apa,
     cod_almacen, num_lote, nis_rad, nif_apa, sec_pm, num_precin, tip_apa,
     co_modelo, error, co_condition, defect, lect, num_os, cod_emp)
    select usuario, f_actual, programa, num_apa, co_marca, trunc(sysdate),
           est_apa, cod_almacen, num_lote, nis_rad, nif_apa, sec_pm,
           num_precin, tip_apa, co_modelo, error, co_condition, defect, lect,
           num_os, cod_emp
      from aparatos a
     where not exists (select 0
              from haparatos
             where num_apa = a.num_apa
               and co_marca = a.co_marca);

end;
