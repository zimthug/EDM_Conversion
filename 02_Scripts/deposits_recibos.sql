declare
  cursor lcur_bill is
    select ' ' facture, f_fact dfac, f_alta dfac_prev, sp.nis_rad,
           sp.sec_nis, sp.cod_tar, sp.cod_unicom, cs.imp_cargo bill_amount,
           0 bill_tax, sp.gr_concepto, sp.cod_mask,
           (select tip_cli from clientes where cod_cli = sp.cod_cli) tip_cli,
           sp.sec_cta, sp.cod_cli, cs.imp_cargo paid, cs.imp_cargo energy,
           0 fixed_charge, 0 radio, 0 garbage_charge, 0 loses, 0 potencia,
           to_char(cs.f_fact, 'yyyymm') periode, sp.f_alta, '01' system_id
      from cargvar cs, sumcon sp
     where sp.nis_rad = cs.nis_rad
       and cs.co_cargo = 'VA160'
       and not exists (select 0
              from recibos
             where nis_rad = sp.nis_rad
               and tip_rec = 'TR045');
  lf_proc_cobro       date;
  lf_previous_date    date;
  lf_fact             date;
  lf_fact_p           date;
  ll_commit           number;
  ll_cod_ref          number;
  ll_excess           number;
  ll_factura          number;
  ll_advance          number;
  ll_imp_cta          number;
  ll_sec_rec          number;
  ll_cnis_rad         number;
  ll_imp_tot_rec      number;
  ll_nis_rad_p        number;
  ll_sec_nis_p        number;
  ls_tip_rec          varchar2(5);
  ls_est_act          varchar2(5);
  ll_paid             number := 0;
  ll_payconc          number := 0;
  ll_sec_concepto     number := 0;
  ll_imp_concepto     number := 0;
  ll_tot_imp_concepto number := 0;
  ls_co_concepto      varchar2(5) := ' ';
  glf_fechanulla      date := to_date(29991231, 'yyyymmdd');
  gls_usuario         varchar2(15) := 'CONV_EDM';
  gls_programa        varchar2(15) := 'CONV_EDM';
begin
  ll_commit    := 0;
  ll_cnis_rad  := 0;
  ll_sec_nis_p := 1;
  ll_nis_rad_p := 1;
  lf_fact_p    := trunc(sysdate);
  --select /*run_id.nextval*/ 0 into conversion_pck.gll_run_id from dual;

  for lcur_bill_rec in lcur_bill loop
    begin
    
      ll_excess      := 1;
      ls_tip_rec     := 'TR045';
      ll_imp_cta     := lcur_bill_rec.paid;
      lf_fact        := lcur_bill_rec.dfac;
      ll_imp_tot_rec := lcur_bill_rec.bill_amount;
    
      if lcur_bill_rec.bill_amount - lcur_bill_rec.paid > 0 then
        ls_est_act := 'ER020';
      elsif lcur_bill_rec.bill_amount - lcur_bill_rec.paid < 0 then
        ll_excess  := 2;
        ls_est_act := 'ER310';
        ll_imp_cta := lcur_bill_rec.bill_amount;
        ll_advance := lcur_bill_rec.bill_amount - lcur_bill_rec.paid;
      else
        ls_est_act := 'ER310';
      end if;
    
      for ll_credit in 1 .. ll_excess loop
      
        if ll_credit = 2 then
          ls_tip_rec     := 'TR502';
          ll_imp_cta     := lcur_bill_rec.paid - lcur_bill_rec.bill_amount;
          ll_imp_tot_rec := lcur_bill_rec.paid - lcur_bill_rec.bill_amount;
        end if;
      
        update sumcon
           set sec_factura = sec_factura + 1
         where nis_rad = lcur_bill_rec.nis_rad
        returning sec_factura into ll_factura;
      
        ll_cod_ref := lcur_bill_rec.nis_rad || lpad(ll_factura, 3, '0');
      
        lf_proc_cobro := lcur_bill_rec.dfac;
      
        select count(*) + 1
          into ll_sec_rec
          from recibos
         where nis_rad = lcur_bill_rec.nis_rad
           and sec_nis = lcur_bill_rec.sec_nis
           and f_fact = lf_fact;
      
        if lcur_bill_rec.nis_rad = ll_nis_rad_p and
           lcur_bill_rec.sec_nis = ll_sec_nis_p and lf_fact = lf_fact_p then
          ll_sec_rec := ll_sec_rec + 1;
        else
          ll_sec_rec := 0;
        end if;
        begin
          insert into recibos
            (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
             imp_tot_rec, est_act, f_est_act, cod_cli, sec_cta, op_cambest,
             f_p_camb_est, num_meses_fact, num_fact, num_fact_anul, sec_mod,
             sec_rec_anul, f_fact_anul, num_plza_abon, imp_cta, tip_cli,
             tip_cta, num_acu, cod_unicom, f_prev_corte, f_vcto_fac,
             ind_recar, ind_multa, num_dias_rec, aj_redon, cod_tar,
             gr_concepto, f_fact_ant, nro_factura, f_cobro, ind_cuota,
             ind_conversion, f_vcto_prox_fac, ind_ajuste, tip_fact,
             f_proc_cobro, ind_impuesto, cod_agencia, cod_sucursal,
             tip_cencobro, sec_remesa, tip_rec, co_cond_fiscal, ind_real_est,
             f_puesta_cobro, ind_gestion_cuenta, simbolo_var, num_ident_sipo,
             num_fiscal, periodo_contable, prioridad, ind_ref, f_fact_regul,
             sec_rec_regul, correo_entrega, distrito_entrega, num_id_sipo,
             sie_simbolo_var, sec_est_act, cod_ref, cod_mask, imp_charges,
             imp_amort, f_last_recargo, f_last_multa, ind_incl_gs,
             shift_camb_est, cod_cli_trn, sec_cta_trn, num_cnto,
             cod_ministry, ind_included, nir_included)
          values
            (gls_usuario, trunc(sysdate), gls_programa, ll_sec_rec,
             lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact,
             ll_imp_tot_rec, ls_est_act, trunc(sysdate),
             lcur_bill_rec.cod_cli, lcur_bill_rec.sec_cta, ' ',
             glf_fechanulla, 0, lcur_bill_rec.facture, 0, 0, 0,
             glf_fechanulla, 0, ll_imp_cta, lcur_bill_rec.tip_cli, 'CU001',
             0, lcur_bill_rec.cod_unicom,
             decode(ll_imp_tot_rec, 0, glf_fechanulla, trunc(sysdate)),
             lf_fact + 14, 2, 2, 0, 0, lcur_bill_rec.cod_tar,
             lcur_bill_rec.gr_concepto, glf_fechanulla, 0, lf_proc_cobro, 2,
             1, glf_fechanulla, 0, 'FT199', lf_proc_cobro, 2, 1,
             lcur_bill_rec.cod_unicom, 'CC001', 0, ls_tip_rec, 'FC540', 1,
             trunc(sysdate), 2, ll_cod_ref, ' ', ' ', glf_fechanulla, 9999,
             2, glf_fechanulla, 0, 0, 0, 0, glf_fechanulla, 1, ll_cod_ref,
             lcur_bill_rec.cod_mask, ll_imp_tot_rec, 0, glf_fechanulla,
             glf_fechanulla, 0, 0, 0, 0, 0, 'IT000', 2, ' ');
        
          lf_fact_p    := lf_fact;
          ll_sec_nis_p := lcur_bill_rec.sec_nis;
          ll_nis_rad_p := lcur_bill_rec.nis_rad;
        
          insert into est_rec
            (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
             sec_est_rec, est_rec, f_inc_est, desc_est_rec)
          values
            (gls_usuario, trunc(sysdate), gls_programa, ll_sec_rec,
             lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact, 1,
             ls_est_act,
             decode(ls_est_act, 'ER020', lf_fact, trunc(sysdate)), ' ');
        
          ll_paid         := ll_imp_tot_rec;
          ll_imp_concepto := ll_imp_tot_rec;
          ll_sec_concepto := 0;
          ls_co_concepto  := 'VA160';
        
          insert into imp_concepto
            (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
             co_concepto, sec_concepto, csmo_fact, prec_concepto,
             imp_concepto, porc_concepto, base_calc_imp, ind_diff, imp_iva,
             ind_pago, desc_pago, imp_cta_cto, nir_srv, nir_asoc, imp_used,
             ind_arrear)
          values
            (gls_usuario, trunc(sysdate), gls_programa, ll_sec_rec,
             lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact,
             ls_co_concepto, ll_sec_concepto, 0, 0, ll_imp_concepto, 0,
             ll_imp_concepto, 0, 0, 1, ' ', ll_paid, ' ', ' ', 0, 0);
        
          update sumcon
             set imp_fian = ll_imp_concepto
           where nis_rad = lcur_bill_rec.nis_rad;
        
        exception
          when dup_val_on_index then
            null;
        end;
      end loop;
    
      ll_cnis_rad := lcur_bill_rec.nis_rad;
    end;
  end loop;
  commit;

end;

/*
select * from recibos where tip_rec = 'TR045';

select * from imp_concepto where co_concepto = 'VA160';
*/
