declare
  cursor ix is
    select * from open_u.tmp_xaixai_dates;
begin
  for x in ix loop
    begin
      update recibos
         set f_fact = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
    
      update est_rec
         set f_fact = x.datavalor, f_inc_est = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
    
      update hfacturacion
         set f_fact = x.datavalor, f_lect = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
    
      /*update hfacturacion h
         set f_lect_ant = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and h.f_lect_ant = x.mes_ano;*/
    
      update imp_concepto
         set f_fact = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
    
      update apmedida_co
         set f_fact = x.datavalor, f_lect = x.datavalor,
             f_trat = x.datavalor
       where nis_rad = x.nis_rad
         and f_fact = x.mes_ano;
    
      update pagos
         set f_fact = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
    
      update sie_asientos_det
         set f_fact = x.datavalor
       where nis_rad = x.nis_rad
         and sec_nis = 1
         and f_fact = x.mes_ano;
         
    exception
      when dup_val_on_index then
        dbms_output.put_line(x.nis_rad || ':' || x.mes_ano);
    end;
  end loop;
end;
