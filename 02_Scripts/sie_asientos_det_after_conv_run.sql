alter session set nls_date_format = 'yyyymmdd';

declare
  cursor c1 is
    select *
      from recibos
     where instr(tip_rec, 'TR045') = 0
       and ind_conversion = 1;

  i           integer := 0;
  j           integer := 0;
  lc_tip_recp varchar(8) := ' ';
  lc_fin_conc varchar(8) := ' ';
  ll_rec_loop number := 0;

begin
  --dbms_output.enable(100000000000000000000000000000000000000000000000000000000);
  for rec in c1 loop
  
    i := i + 1;
  
    declare
      cursor c2_billing is
        select co_concepto concepts, sum(imp_concepto - imp_cta_cto) balan,
               sum(csmo_fact) csmo
          from imp_concepto
         where nis_rad = rec.nis_rad
           and f_fact = rec.f_fact
           and sec_nis = rec.sec_nis
           and sec_rec = rec.sec_rec
         group by co_concepto;
    
    Begin
      For cl_rec2 in c2_billing loop
        j := j + 1;
        if (cl_rec2.balan) >= 0 then
        
          --dbms_output.put_line(rec.nis_rad||'   '||cl_rec2.concepts);
          
          select CO_CONCEPTO
            into lc_fin_conc
            from sie_grupo_concepto
           where co_conc_fact = cl_rec2.concepts
             and TIP_CONC_FACT = 'XA006'
             and SIGNO_CONC_FACT = 1;
        else
          select CO_CONCEPTO
            into lc_fin_conc
            from sie_grupo_concepto
           where co_conc_fact = cl_rec2.concepts
             and TIP_CONC_FACT = 'XA006'
             and SIGNO_CONC_FACT = 2;
        end if;
      
        INSERT INTO SIE_ASIENTOS_DET
          (cod_cli, sec_cta, nis_rad, sec_nis, f_fact, sec_rec, tip_rec,
           cod_unicom, tip_cli, tip_cta, cod_tar, cod_agencia, cod_sucursal,
           f_cobro, tip_fact, est_ant, est_act, num_fact, f_puesta_cobro,
           f_actual_proc, periodo_contable, co_sie_modul, usuario, f_actual,
           programa, co_operacion, co_concepto, importe, id_sie_det,
           id_sie_det_op, id_sie_sum, sie_forma_pago, ind_onl_cb, f_proc_cb,
           cb_error, cod_mask, tip_reg_cb, balance_period, f_vcto,
           spec_signal, cod_ministry, cod_revenue, tip_balance_cb, cod_annex,
           f_contable, doc_soporte, tip_reg, tip_reg_bdg, tip_balance_bdg,
           csmo_fact)
        VALUES
          (rec.cod_cli, rec.sec_cta, rec.nis_rad, rec.sec_nis,
           to_date(rec.f_fact, 'YYYYMMDD'), rec.sec_rec, rec.tip_rec,
           rec.cod_unicom, rec.tip_cli, rec.tip_cta, rec.cod_tar,
           rec.cod_agencia, rec.cod_unicom, to_date(rec.f_cobro, 'YYYYMMDD'),
           rec.tip_fact, 'ER010', 'ER020', rec.num_fact,
           to_date(rec.f_puesta_cobro, 'YYYYMMDD'),
           to_date(rec.f_actual, 'YYYYMMDD'),
           to_date(rec.f_actual, 'YYYYMMDD'), 'MI001', 'SIE_CONV',
           to_date(rec.f_actual, 'YYYYMMDD'), 'ICCBCONV', 'OC100',
           lc_fin_conc, cl_rec2.balan,
           to_number('14' || to_char(rec.nis_rad)), j, 10, 'XM999', 2,
           to_date(rec.f_fact, 'YYYYMMDD'), 'AI999', 15360, 'TY100',
           substr(to_date(rec.f_fact, 'YYYYMMDD'), 1, 6), rec.f_vcto_fac,
           'SS999', 'IT000', 'XR999', 'YX001', rec.tip_fact,
           to_date(rec.f_fact, 'YYYYMMDD'), ' ', 'TY001', 'TY100', 'YY101',
           cl_rec2.csmo);
      
      End loop;
      lc_fin_conc := ' ';
      j           := 0;
    End;
  
    if (i mod 100 = 0) then
      commit;
    end if;
  
  end loop;
  commit;
end;
/
