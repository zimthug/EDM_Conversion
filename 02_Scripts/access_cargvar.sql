declare
  cursor lcur_deposits is
    select xb.mes_ano deposit_date, xb.nis_rad, sec_nis, sp.cod_unicom,
           sp.tip_cli, sp.cod_cli, xb.valor - xb.cobranca deposit,
           sp.cod_tar
      from edmaccess.xaixai_balances xb, int_supply sp
     where codoperacao in (778)
       and xb.nis_rad = sp.nis_rad;
  ll_sec_cargo  number;
  ls_co_cargo   varchar2(5) := 'VA145';
  lf_fechanulla date := to_date('29991231', 'yyyymmdd');
begin
  for lcur_deposits_rec in lcur_deposits loop
  
    select count(*)
      into ll_sec_cargo
      from cargvar c
     where nis_rad = lcur_deposits_rec.nis_rad;
  
    insert into cargvar
      (usuario, f_actual, programa, sec_rec, nis_rad, sec_nis, f_fact,
       co_cargo, sec_cargo, est_act, f_est_act, num_fact, doc_soporte,
       f_prod_inic, cod_unicom, cod_agencia, cod_sucursal, tip_cli, cod_tar,
       imp_cargo, imp_fact_cargo, imp_fact_total, aj_redon, cod_cli, sec_cta,
       f_cobro, f_extracto, numero_extracto, sec_movimiento,
       periodo_contable, clave_coberror, nis_rad_regul, sec_nis_regul,
       tip_cta, sie_simbolo_var, nir_refer, num_cheque, cod_agencia_cheque,
       cod_sucursal_cheque, porc_rebaja, texto, datos, sie_forma_pago,
       cod_ministry)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', 0, lcur_deposits_rec.nis_rad,
       lcur_deposits_rec.sec_nis, lcur_deposits_rec.deposit_date,
       ls_co_cargo, ll_sec_cargo, 'EV002', lcur_deposits_rec.deposit_date,
       ' ', ' ', lcur_deposits_rec.deposit_date,
       lcur_deposits_rec.cod_unicom, 0, 0, lcur_deposits_rec.tip_cli,
       lcur_deposits_rec.cod_tar, lcur_deposits_rec.deposit,
       lcur_deposits_rec.deposit, lcur_deposits_rec.deposit, 0,
       lcur_deposits_rec.cod_cli, 1, lcur_deposits_rec.deposit_date,
       lf_fechanulla, 0, 0, lf_fechanulla, 0, 0, 0, 'CU001', lf_fechanulla,
       ' ', ' ', 0, 0, 0, ' ', ' ', 'XM999', 'IT000');
  end loop;
end p30_deposits;
