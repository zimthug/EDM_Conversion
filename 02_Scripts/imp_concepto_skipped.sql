declare
  cursor ix is
    select xa.*, re.nis_rad, re.sec_nis, re.sec_rec, re.f_fact, imp_tot_rec,
           imp_cta
      from open_u.xaixai_balances xa, recibos re, rel_nis_rutafol rl,
           account_assoc aa
     where rl.folio = lpad(xa.zona, 2, 0) || '-' || xa.instalacao
       and rl.nis_rad = aa.nis_rad
       and aa.nis_rad_sub = re.nis_rad
       and re.f_fact = datavalor
       and re.imp_tot_rec = valor;
  --and re.imp_cta > 0;
  --and re.nis_rad = 200052812;
  ls_co_concepto  varchar2(5);
  ll_imp_concepto number;
begin
  for x in ix loop
    begin
      for i in 1 .. 4 loop
      
        if i = 1 then
          ls_co_concepto  := 'CC500';
          ll_imp_concepto := x.iva;
        elsif i = 2 then
          ls_co_concepto  := 'CC120';
          ll_imp_concepto := x.taxaradio;
        elsif i = 3 then
          ls_co_concepto  := 'CC100';
          ll_imp_concepto := x.taxafixa;
        elsif i = 4 then
          ls_co_concepto  := 'CC130';
          ll_imp_concepto := x.taxalixo;
        end if;
      
        insert into imp_concepto
          select usuario, f_actual, programa, sec_rec, nis_rad, sec_nis,
                 f_fact, ls_co_concepto, i + 1 sec_concepto, csmo_fact,
                 prec_concepto, ll_imp_concepto, porc_concepto,
                 ll_imp_concepto base_calc_imp, ind_diff, imp_iva, ind_pago,
                 desc_pago, imp_cta_cto, nir_srv, nir_asoc, imp_used,
                 ind_arrear
            from imp_concepto
           where nis_rad = x.nis_rad
             and sec_nis = x.sec_nis
             and sec_rec = x.sec_rec
             and f_fact = x.f_fact
             and sec_concepto = 1;
      
      end loop;
      ll_imp_concepto := x.valor -
                         (x.iva + x.taxaradio + x.taxafixa + x.taxalixo);
    
      update imp_concepto
         set imp_concepto = ll_imp_concepto, base_calc_imp = ll_imp_concepto,
             co_concepto = 'CC261'
       where nis_rad = x.nis_rad
         and sec_nis = x.sec_nis
         and sec_rec = x.sec_rec
         and f_fact = x.f_fact
         and sec_concepto = 1;
    exception
      when dup_val_on_index then
        dbms_output.put_line(x.nis_rad || ':' ||
                             to_char(x.f_fact, 'yyyymmdd'));
    end;
  end loop;
end;

--select * from imp_concepto where nis_rad = 200052812 and f_fact = to_date('20140731', 'yyyymmdd')
