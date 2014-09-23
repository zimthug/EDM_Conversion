CREATE OR REPLACE PROCEDURE conversion_cuentas_cu is
  cursor lcur_cuentas_cu is
    select *
      from int_supply s
     where nif is not null
       and cod_cli is not null
       and sec_cta is null
       and not exists
     (select 0 from sgc.cuentas_cu where cod_cli = s.cod_cli);
  ll_commit            number := 0;
  ll_sec_cta           number := 1;
  ll_tip_cta           varchar2(6) := 'CU001';
  ll_tip_env           varchar2(6) := 'TE001';
  ll_co_mod_env        varchar2(6) := 'EN001';
  ll_cod_ministry      varchar2(6) := 'IT000';
  ll_tip_corte         varchar2(6) := 'DS002';
  ll_co_calidad_cuenta varchar2(6) := 'CU001';
  ls_program_name      varchar2(15) := 'CP3_CUENTAS_CU';
begin
  select run_id.nextval into conversion_pck.gll_run_id from dual;

  --Log first to begin the program
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'STARTING', p_status => 'STARTING',
                        p_row_count => 0);
  commit;

  for lcur_cuentas_cu_rec in lcur_cuentas_cu loop
    begin
    
      insert into sgc.cuentas_cu
        (usuario, f_actual, programa, cod_cli, sec_cta, co_motnocort,
         resp_no_cort, age_cbr_esp, num_cort, nif, num_ult_acu, cod_calle,
         num_puerta, duplicador, cgv_cta, tip_cta, num_copias, tip_env,
         co_mod_env, f_camb, ind_tit_cli, descript_cta, co_calidad_cuenta,
         ref_dir, apart_postal, ind_gestion_cuenta, saldo,
         dia_vcto_anticipos, imp_limite_domic, ind_confirm_corte, cod_post,
         ind_no_trat_rec, cod_ref, account_id, f_reconcil, ind_reconcil,
         cod_ministry, tip_corte, f_tip_pay, imp_pre)
      values
        (conversion_pck.gls_programa, trunc(sysdate),
         conversion_pck.gls_programa, lcur_cuentas_cu_rec.cod_cli,
         nvl(lcur_cuentas_cu_rec.sec_cta, 1),
         nvl(lcur_cuentas_cu_rec.co_motnocort, 'NC010'), ' ',
         lcur_cuentas_cu_rec.cod_unicom, 0, lcur_cuentas_cu_rec.nif, 0,
         lcur_cuentas_cu_rec.cod_calle,
         nvl(lcur_cuentas_cu_rec.num_puerta, 0),
         lcur_cuentas_cu_rec.duplicador, ' ', ll_tip_cta, 1, ll_tip_env,
         ll_co_mod_env, lcur_cuentas_cu_rec.f_alta
         /*to_date('29991231', 'yyyymmdd')*/, 1, ' ', ll_co_calidad_cuenta,
         ' ', ' ', 2, 0, 0, 0, 2, '  ', 2, ' ', 0, trunc(sysdate), 1,
         ll_cod_ministry, ll_tip_corte, to_date('19000101', 'yyyymmdd'), 0);
    
      update int_supply
         set sec_cta = ll_sec_cta
       where conv_id = lcur_cuentas_cu_rec.conv_id;
    
      ll_commit := ll_commit + 1;
    
      if mod(ll_commit, 5000) = 0 then
        --Log commits at 5000 rows
        conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                              p_program_name => ls_program_name,
                              p_message => 'COMMITED', p_status => 'RUNNING',
                              p_row_count => ll_commit);
        commit;
      end if;
    exception
      when others then
        --log errors and continue.
        conversion_pck.error_logger(p_error_msg => sqlerrm,
                                    p_run_id => conversion_pck.gll_run_id,
                                    p_program_name => ls_program_name,
                                    p_tip_id => 'CONV',
                                    p_id_number => lcur_cuentas_cu_rec.conv_id);
    END;
  END LOOP;

  --Log end of running
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'ENDING', p_status => 'ENDING',
                        p_row_count => ll_commit);
  commit;
end conversion_cuentas_cu;
/
