declare
  cursor ix is
    select *
      from recibos r
     where not exists (select 0
              from imp_concepto
             where nis_rad = r.nis_rad
               and sec_nis = r.sec_nis
               and sec_rec = r.sec_rec
               and f_fact = r.f_fact)
    /*and (programa != 'CONV_EDM')
    or (est_act = 'ER020')*/
   and 1 = 2 ;
  ls_co_concepto varchar2(5);
begin
  for x in ix loop
  
    if x.tip_rec = 'TR110' then
      ls_co_concepto := 'CC261';
    elsif x.tip_rec = 'TR050' then
      ls_co_concepto := 'CC261';
    end if;
  
    insert into imp_concepto
      (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
       co_concepto, sec_concepto, csmo_fact, prec_concepto, imp_concepto,
       porc_concepto, base_calc_imp, ind_diff, imp_iva, ind_pago, desc_pago,
       imp_cta_cto, nir_srv, nir_asoc, imp_used, ind_arrear)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.sec_rec, x.nis_rad,
       x.sec_nis, x.f_fact, ls_co_concepto, 1, 0, 0, x.imp_tot_rec, 0,
       x.imp_tot_rec, 0, 0, 1, ' ', x.imp_cta, ' ', ' ', 0, 0);
  
    if x.imp_cta > 0 and x.programa != 'CONV_EDM' then
      insert into pagos_concepto
        (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
         sec_pago, co_concepto, sec_concepto, csmo_fact, imp_total,
         imp_base_iva, imp_iva, ind_anulado)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.sec_rec, x.nis_rad,
         x.sec_nis, x.f_fact, 1, ls_co_concepto, 1, 0, x.imp_tot_rec,
         x.imp_tot_rec, 0, 2);
    end if;
  
  end loop;

  declare
    cursor ip is
      select p.*, r.co_concepto
        from imp_concepto r, pagos p
       where not exists (select 0
                from pagos_concepto
               where nis_rad = r.nis_rad
                 and sec_nis = r.sec_nis
                 and sec_rec = r.sec_rec
                 and f_fact = r.f_fact)
         and p.nis_rad = r.nis_rad
         and p.sec_nis = r.sec_nis
         and p.sec_rec = r.sec_rec
         and p.f_fact = r.f_fact;
  begin
    for x in ip loop
      insert into pagos_concepto
        (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
         sec_pago, co_concepto, sec_concepto, csmo_fact, imp_total,
         imp_base_iva, imp_iva, ind_anulado)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.sec_rec, x.nis_rad,
         x.sec_nis, x.f_fact, x.sec_pago, x.co_concepto, 1, 0, x.imp_pago,
         x.imp_pago, 0, 2);
    end loop;
  end;
end;
