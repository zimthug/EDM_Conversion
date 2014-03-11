declare
  cursor lcur_bill is
    select nis_rad, sec_nis, f_res_cont, cod_mask, 0 garbage_charge,
           cod_unicom, cod_tar, gr_concepto, 0 bill_tax, 'TC000' tip_cli,
           0 radio, 0 fixed_charge, '000000' facture, sec_cta, cod_cli,
           0 energy,
           (select max(f_lect) from apmedida_co where nis_rad = s.nis_rad) dfac,
           0 paid, 0 bill_amount
      from sumcon s
     where est_sum = 'EC012'
       and not exists
     (select 0 from hfacturacion where nis_rad = s.nis_rad)
       and exists
     (select 0 from apmedida_co where nis_rad = s.nis_rad);
  lf_fact             date;
  ll_commit           number;
  ll_cod_ref          number;
  ll_excess           number;
  ll_factura          number;
  ll_advance          number;
  ll_imp_cta          number;
  ll_cnis_rad         number;
  ll_imp_tot_rec      number;
  ls_tip_rec          varchar2(5);
  ls_est_act          varchar2(5);
  ll_paid             number := 0;
  ll_payconc          number := 0;
  ll_sec_concepto     number := 0;
  ll_imp_concepto     number := 0;
  ll_tot_imp_concepto number := 0;
  ls_co_concepto      varchar2(5) := ' ';
  gls_usuario         varchar2(15) := 'CONV_EDM';
  gls_programa        varchar2(15) := 'CONV_EDM';
  glf_fechanulla      date := to_date(29991231, 'yyyymmdd');
begin
  ll_commit   := 0;
  ll_cnis_rad := 0;
  for lcur_bill_rec in lcur_bill loop
    begin
    
      lf_fact        := lcur_bill_rec.dfac;
      ls_tip_rec     := 'TR110';
      ll_excess      := 1;
      ll_imp_cta     := lcur_bill_rec.paid;
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
    
      for w in 1 .. ll_excess loop
      
        if w = 2 then
          ls_tip_rec     := 'TR502';
          ll_imp_cta     := lcur_bill_rec.paid - lcur_bill_rec.bill_amount;
          ll_imp_tot_rec := lcur_bill_rec.paid - lcur_bill_rec.bill_amount;
        end if;
      
        update sumcon
           set sec_factura = sec_factura + 1
         where nis_rad = lcur_bill_rec.nis_rad
        returning sec_factura into ll_factura;
      
        ll_cod_ref := lcur_bill_rec.nis_rad || lpad(ll_factura, 3, '0');
      
        insert into recibos
          (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
           imp_tot_rec, est_act, f_est_act, cod_cli, sec_cta, op_cambest,
           f_p_camb_est, num_meses_fact, num_fact, num_fact_anul, sec_mod,
           sec_rec_anul, f_fact_anul, num_plza_abon, imp_cta, tip_cli,
           tip_cta, num_acu, cod_unicom, f_prev_corte, f_vcto_fac, ind_recar,
           ind_multa, num_dias_rec, aj_redon, cod_tar, gr_concepto,
           f_fact_ant, nro_factura, f_cobro, ind_cuota, ind_conversion,
           f_vcto_prox_fac, ind_ajuste, tip_fact, f_proc_cobro, ind_impuesto,
           cod_agencia, cod_sucursal, tip_cencobro, sec_remesa, tip_rec,
           co_cond_fiscal, ind_real_est, f_puesta_cobro, ind_gestion_cuenta,
           simbolo_var, num_ident_sipo, num_fiscal, periodo_contable,
           prioridad, ind_ref, f_fact_regul, sec_rec_regul, correo_entrega,
           distrito_entrega, num_id_sipo, sie_simbolo_var, sec_est_act,
           cod_ref, cod_mask, imp_charges, imp_amort, f_last_recargo,
           f_last_multa, ind_incl_gs, shift_camb_est, cod_cli_trn,
           sec_cta_trn, num_cnto, cod_ministry, ind_included, nir_included)
        values
          (gls_usuario, trunc(sysdate), gls_programa || '-N', w,
           lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact,
           ll_imp_tot_rec, ls_est_act, trunc(sysdate), lcur_bill_rec.cod_cli,
           lcur_bill_rec.sec_cta, ' ', glf_fechanulla, 0,
           lcur_bill_rec.facture, 0, 0, 0, glf_fechanulla, 0, ll_imp_cta,
           lcur_bill_rec.tip_cli, 'CU001', 0, lcur_bill_rec.cod_unicom,
           decode(ll_imp_tot_rec, 0, glf_fechanulla, trunc(sysdate)),
           lf_fact + 14, 2, 2, 0, 0, lcur_bill_rec.cod_tar,
           lcur_bill_rec.gr_concepto, glf_fechanulla, 0,
           decode(ll_imp_tot_rec, 0, glf_fechanulla, trunc(sysdate)), 2, 1,
           glf_fechanulla, 0, 'FT011',
           decode(ll_imp_tot_rec, 0, glf_fechanulla, trunc(sysdate)), 2, 1,
           lcur_bill_rec.cod_unicom, 'CC001', 0, ls_tip_rec, 'FC540', 1,
           trunc(sysdate), 2, ll_cod_ref, ' ', ' ', glf_fechanulla, 9999, 2,
           glf_fechanulla, 0, 0, 0, 0, glf_fechanulla, 1, ll_cod_ref,
           lcur_bill_rec.cod_mask, ll_imp_tot_rec, 0, glf_fechanulla,
           glf_fechanulla, 0, 0, 0, 0, 0, 'IT000', 2, ' ');
      
        if w = 1 then
          insert into hfacturacion
            (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
             csmo_fact, pot_fact, imp_fact, f_fact_sust, ind_rest,
             ind_val_fact, tip_fact, imp_cv, num_cv_fact, mod_estm,
             sec_rec_sust, csmo_react, pot_leida, cont_trans_pot_ant,
             f_prox_vto, csmo_fact_punta, csmo_fact_valle, csmo_fact_llano,
             pot_fact_punta, pot_fact_valle, pot_fact_llano, pot_leida_punta,
             pot_leida_valle, pot_leida_llano, ind_f_lect_control,
             ind_f_lvnto, imp_anticipos, num_anticipos_fact, f_lect,
             f_lect_ant, imp_iva_antic, tip_cta, tip_rec, imp_charges,
             period, period_tip_per_fact)
          values
            (gls_usuario, trunc(sysdate), gls_programa, 1,
             lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact, 0, 0,
             ll_imp_tot_rec, glf_fechanulla, 1, 1, 'FT011', 0, 0, 0, 0, 0, 0,
             0, glf_fechanulla, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0,
             lf_fact, glf_fechanulla, 0, 'CU001', 'TR110', ll_imp_tot_rec,
             to_char(sysdate, 'yyyymm'), 'PF012');
        end if;
      
        insert into est_rec
          (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
           sec_est_rec, est_rec, f_inc_est, desc_est_rec)
        values
          (gls_usuario, trunc(sysdate), gls_programa, w,
           lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact, 1,
           ls_est_act, trunc(sysdate), ' ');
      
        if w = 2 then
          ll_sec_concepto := 1;
          ls_co_concepto  := 'VA502';
          ll_paid         := ll_imp_tot_rec;
          ll_imp_concepto := ll_imp_tot_rec;
        
          insert into imp_concepto
            (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
             co_concepto, sec_concepto, csmo_fact, prec_concepto,
             imp_concepto, porc_concepto, base_calc_imp, ind_diff, imp_iva,
             ind_pago, desc_pago, imp_cta_cto, nir_srv, nir_asoc, imp_used,
             ind_arrear)
          values
            (gls_usuario, trunc(sysdate), gls_programa, w,
             lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact,
             ls_co_concepto, ll_sec_concepto, 0, 0, ll_imp_concepto, 0,
             ll_imp_concepto, 0, 0, 1, ' ', ll_paid, ' ', ' ', 0, 0);
        end if;
      
      end loop;
      --Concepts
      ll_payconc := lcur_bill_rec.paid;
    
      ll_sec_concepto := 0;
    
      for i in 1 .. 5 loop
        ll_sec_concepto := ll_sec_concepto + 1;
      
        if i = 1 then
          ls_co_concepto  := 'CC503';
          ll_imp_concepto := lcur_bill_rec.bill_tax;
        elsif i = 2 then
          ls_co_concepto  := 'CC120';
          ll_imp_concepto := lcur_bill_rec.radio;
        elsif i = 3 then
          ls_co_concepto  := 'CC100';
          ll_imp_concepto := lcur_bill_rec.fixed_charge;
        elsif i = 4 then
          ls_co_concepto  := 'CC130';
          ll_imp_concepto := lcur_bill_rec.garbage_charge;
        elsif i = 5 then
          ls_co_concepto  := 'CC261';
          ll_imp_concepto := lcur_bill_rec.energy;
        
        end if;
      
        ll_tot_imp_concepto := ll_tot_imp_concepto + ll_imp_concepto;
      
        if ll_payconc > 0 then
          if ll_payconc > ll_imp_concepto then
            ll_paid    := ll_imp_concepto;
            ll_payconc := ll_payconc - ll_imp_concepto;
          else
            ll_paid    := ll_payconc;
            ll_payconc := 0;
          end if;
        else
          ll_paid := 0;
        end if;
      
        ll_imp_concepto := nvl(ll_imp_concepto, 0);
      
        insert into imp_concepto
          (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
           co_concepto, sec_concepto, csmo_fact, prec_concepto, imp_concepto,
           porc_concepto, base_calc_imp, ind_diff, imp_iva, ind_pago,
           desc_pago, imp_cta_cto, nir_srv, nir_asoc, imp_used, ind_arrear)
        values
          (gls_usuario, trunc(sysdate), gls_programa, 1,
           lcur_bill_rec.nis_rad, lcur_bill_rec.sec_nis, lf_fact,
           ls_co_concepto, ll_sec_concepto, 0, 0, ll_imp_concepto, 0,
           ll_imp_concepto, 0, 0, 1, ' ', ll_paid, ' ', ' ', 0, 0);
      end loop;
    
      if ll_cnis_rad <> lcur_bill_rec.nis_rad then
        ll_commit := ll_commit + 1;
      
        if mod(ll_commit, 1000) = 0 then
          commit;
        end if;
      end if;
    
      ll_cnis_rad := lcur_bill_rec.nis_rad;
    exception
      when others then
        dbms_output.put_line(sqlerrm || '--> ' || lcur_bill_rec.nis_rad);
    end;
  end loop;
  commit;

  --Cod_Ref Updates    
  update recibos
     set cod_ref = to_char(cod_ref) ||
                    substr(to_char(11 -
                                   mod(((to_number(substr(to_char(cod_ref), 1,
                                                          1)) * 2) +
                                       (to_number(substr(to_char(cod_ref), 2,
                                                          1)) * 3) +
                                       (to_number(substr(to_char(cod_ref), 3,
                                                          1)) * 4) +
                                       (to_number(substr(to_char(cod_ref), 4,
                                                          1)) * 5) +
                                       (to_number(substr(to_char(cod_ref), 5,
                                                          1)) * 6) +
                                       (to_number(substr(to_char(cod_ref), 6,
                                                          1)) * 7) +
                                       (to_number(substr(to_char(cod_ref), 7,
                                                          1)) * 2) +
                                       (to_number(substr(to_char(cod_ref), 8,
                                                          1)) * 3) +
                                       (to_number(substr(to_char(cod_ref), 9,
                                                          1)) * 4) +
                                       (to_number(substr(to_char(cod_ref), 10,
                                                          1)) * 5) +
                                       (to_number(substr(to_char(cod_ref), 11,
                                                          1)) * 6) +
                                       (to_number(substr(to_char(cod_ref), 12,
                                                          1)) * 7)), 11)), -1)
   where trunc(sysdate) = trunc(f_actual)
     and ind_conversion = 1
     and programa = gls_programa || '-N';

  update recibos
     set programa = gls_programa
   where programa = gls_programa || '-N';

  commit;
end p20_billing_galatee;
