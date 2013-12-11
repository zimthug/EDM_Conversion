create or replace procedure conversion_sumcon is
  /**
  * @author vomondi@indracompany.com
  * @author tmlangeni@eservicios.indracompany.com
  * @version 20131130
  *
  */
  cursor lcur_sumcon is
    select *
      from int_supply
     where nis_rad is null
       and cod_cli is not null
       and sec_cta is not null;
  ll_nis_rad             number;
  ll_nis_rad_2           number;
  ll_nis_rad_7           number;
  ll_commit              number := 0;
  ll_cod_cnae            number := 1000;
  ll_prioridad           number := 9999;
  ll_cod                 varchar2(6) := 'RG000';
  ll_datos               varchar2(50) := ' ';
  ll_tip_contr           varchar2(6) := 'PC000';
  ll_tip_per_fact        varchar2(6) := 'PF012';
  ll_co_recar_fp         varchar2(6) := 'RP001';
  ll_tip_multa           varchar2(6) := 'MU001';
  ll_tip_recargo         varchar2(6) := 'RC001';
  ll_tip_per_lect        varchar2(6) := 'RU012';
  ll_tip_asoc            varchar2(6) := 'IA000';
  ll_cod_calc_pot        varchar2(6) := 'CP000';
  ll_tip_alquiler        varchar2(6) := '/0/0/';
  ll_tip_compensacion    varchar2(6) := '/0/0/';
  ll_tip_autogenerador   varchar2(6) := '/0/0/';
  ll_tip_distr_anticipos varchar2(6) := 'DB000';
  ll_est_gest_impag      varchar2(6) := 'DR001';
  ll_rent_revision       varchar2(6) := '/0/0/';
  ll_tip_csmo_rang       varchar2(6) := 'UR001';
  ls_program_name        varchar2(15) := 'CP3_sumcon';
  lf_fecha_nulla         date := conversion_pck.glf_fechanulla;
begin
  select run_id.nextval into conversion_pck.gll_run_id from dual;

  --Log first to begin the program
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'STARTING', p_status => 'STARTING',
                        p_row_count => 0);
  commit;

  for lcur_sumcon_rec IN lcur_sumcon loop
    begin
    
      select sgc.nis03.nextval into ll_nis_rad_2 from dual;
    
      select convis.nis_rad_7.nextval into ll_nis_rad_7 from dual;
    
      for i in 1 .. 2 loop
        if i = 1 then
          ll_nis_rad                     := ll_nis_rad_2;
          lcur_sumcon_rec.tip_suministro := nvl(lcur_sumcon_rec.tip_suministro,
                                                'SU001');
          ll_datos                       := '/1/14/0/0/ / / / /1/ / /0/0/0/1/0/';
        else
          lcur_sumcon_rec.pot            := 0;
          lcur_sumcon_rec.est_sum        := 'EC100';
          lcur_sumcon_rec.co_estm        := 'ME000';
          lcur_sumcon_rec.tip_suministro := 'SU900';
          ll_datos                       := '/1/1/6/';
          ll_nis_rad                     := to_char(ll_nis_rad_7) ||
                                            substr(to_char(11 -
                                                           mod(((to_number(substr(to_char(ll_nis_rad_7),
                                                                                  1,
                                                                                  1)) * 2) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  2,
                                                                                  1)) * 3) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  3,
                                                                                  1)) * 4) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  4,
                                                                                  1)) * 5) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  5,
                                                                                  1)) * 6) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  6,
                                                                                  1)) * 7) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  7,
                                                                                  1)) * 2) +
                                                               (to_number(substr(to_char(ll_nis_rad_7),
                                                                                  8,
                                                                                  1)) * 3)),
                                                               11)), -1);
        end if;
      
        ll_cod_cnae := lcur_sumcon_rec.cod_cnae;
      
        insert into intfopen.sumcon
          (usuario, f_actual, programa, nis_rad, sec_nis, est_sum, cod_cli,
           sec_cta, pot, cod_tar, gr_concepto, f_mod_cont, tip_contr,
           sec_mod, f_baja, ind_lvto, f_corte, pot_valle, csmo_fijo,
           hora_util, tip_per_fact, durac_cont, num_cort, cont_lect_dif,
           estm_anual, estm_cons, num_plza, imp_fian, f_dvol_fian, aus_cons,
           ind_modif_cont, f_res_cont, cont_trans_pot, co_recar_fp,
           f_trans_pot, cod_cnae, nis_solidario, cod_cli_solidario,
           sec_nis_solidario, ind_an_nodet, ind_bonif, ind_bonif_react,
           pot_punta, pot_llano, co_estm, cont_lect_rep, tip_multa,
           tasa_multa, tip_recargo, tasa_recargo, grupo_famil, f_alta_cont,
           cgv_sum, nif, f_alta, num_exp, tip_tension, tip_fase,
           pot_max_admis, tip_conexion, cod_tar_rec, tip_suministro,
           tip_per_lect, tip_asoc, imp_derechos_conex, kwh_deposito_fianza,
           cod_unicom, co_an_vip, num_ident_sipo, ind_lect_control,
           sec_factura, tip_distr_anticipos, cod_calc_pot, tip_alquiler,
           tip_compensacion, tip_autogenerador, porc_st_trans, porc_vt_trans,
           porc_nt_trans, porc_red_pot, pot_minima, cos_fi, prioridad,
           desc_sum, ciclo_sipo, datos, f_baja_estm, ind_gen, cod_mask, cod,
           cod_emp, est_gest_impag, f_act_gest_impag, ind_prefact,
           cod_cli_agent, cod_cli_guarant, sec_cta_guarant, rent_revision,
           usuario_mod, f_mod_hist, tip_csmo_rang)
        values
          (conversion_pck.gls_programa, trunc(sysdate),
           conversion_pck.gls_programa, ll_nis_rad, 1,
           lcur_sumcon_rec.est_sum, lcur_sumcon_rec.cod_cli,
           lcur_sumcon_rec.sec_cta, nvl(lcur_sumcon_rec.pot, 0),
           lcur_sumcon_rec.cod_tar, lcur_sumcon_rec.gr_concepto,
           lcur_sumcon_rec.f_alta, ll_tip_contr, 0, lcur_sumcon_rec.f_baja,
           nvl(lcur_sumcon_rec.ind_lvto, 2), lf_fecha_nulla, 0, 0, 0,
           ll_tip_per_fact, 0, 0, 0, 0, 0, 0, 0, lf_fecha_nulla, 0, 2,
           lcur_sumcon_rec.f_alta, 0, ll_co_recar_fp, lf_fecha_nulla,
           nvl(ll_cod_cnae, 9999), 0, 0, 0, 2, 2, 2, 0, 0,
           nvl(lcur_sumcon_rec.co_estm, 'ME000'), 0, ll_tip_multa, 0,
           ll_tip_recargo, 0, 1, lcur_sumcon_rec.f_alta, ' ',
           lcur_sumcon_rec.nif, lcur_sumcon_rec.f_alta, '  ',
           nvl(lcur_sumcon_rec.tip_tension, 'TT000'),
           nvl(lcur_sumcon_rec.tip_fase, 'FA999'), 0,
           nvl(lcur_sumcon_rec.tip_conexion, 'CX999'), ' ',
           lcur_sumcon_rec.tip_suministro, ll_tip_per_lect, ll_tip_asoc, 0,
           0, lcur_sumcon_rec.cod_unicom,
           nvl(lcur_sumcon_rec.co_an_vip, 'VP999'), ' ', 2, 1,
           ll_tip_distr_anticipos, ll_cod_calc_pot, ll_tip_alquiler,
           ll_tip_compensacion, ll_tip_autogenerador, 0, 0, 0, 0, 0, 0.8,
           ll_prioridad, ' ', 0, ll_datos, lf_fecha_nulla, 2,
           lcur_sumcon_rec.cod_mask, ll_cod, 0, ll_est_gest_impag,
           lf_fecha_nulla, 2, 0, 0, 0, ll_rent_revision,
           conversion_pck.gls_programa, trunc(sysdate), ll_tip_csmo_rang);
      
      end loop;
    
      --ACCOUNT ASSOCIATION
      insert into sgc.account_assoc
        (usuario, f_actual, programa, nis_rad, nis_rad_sub, f_val, f_anul,
         perc_usage, f_last_bill, sec_nis_sub, sec_nis)
      values
        (conversion_pck.gls_programa, trunc(sysdate),
         conversion_pck.gls_programa, ll_nis_rad_7, ll_nis_rad_2,
         lcur_sumcon_rec.f_alta, lcur_sumcon_rec.f_baja, 1, lf_fecha_nulla,
         1, NVL(lcur_sumcon_rec.sec_nis, 1));
    
      --REL_NIS_RUTAFOL
      if lcur_sumcon_rec.centre <> '999' then
        insert into rel_nis_rutafol
          (usuario, f_actual, programa, ruta, folio, nis_rad, sec_nis,
           cod_cli, ref_num)
        values
          (conversion_pck.gls_programa, trunc(sysdate),
           conversion_pck.gls_programa, 0,
           lcur_sumcon_rec.centre || '-' || lcur_sumcon_rec.client || '-' ||
            lcur_sumcon_rec.ordre, ll_nis_rad_7, 1, lcur_sumcon_rec.cod_cli,
           lcur_sumcon_rec.centre || '-' || lcur_sumcon_rec.client || '-' ||
            lcur_sumcon_rec.ordre);
      end if;
    
      update sgc.cuentas_cu
         set account_id = ll_nis_rad_7
       where cod_cli = lcur_sumcon_rec.cod_cli
         and sec_cta = lcur_sumcon_rec.sec_cta;
    
      update int_supply
         set nis_rad = ll_nis_rad_2, sec_nis = 1
       where conv_id = lcur_sumcon_rec.conv_id;
    
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
        --Log errors and continue.
        conversion_pck.error_logger(p_error_msg => sqlerrm,
                                    p_run_id => conversion_pck.gll_run_id,
                                    p_program_name => ls_program_name,
                                    p_tip_id => 'CONV',
                                    p_id_number => lcur_sumcon_rec.conv_id);
      
        commit;
    end;
  end loop;

  /*  Sumcon.Pot Updates  */
  begin
    update sumcon
       set pot = 2200
     where tip_suministro = 'SU001'
       and pot = 2;
  
    update sumcon
       set pot = 1100
     where tip_suministro = 'SU001'
       and pot = 1;
  
    update sumcon
       set pot = 3300
     where tip_suministro = 'SU001'
       and pot = 3;
  
    update sumcon
       set pot = 6600
     where tip_suministro = 'SU001'
       and pot = 7;
  
    update sumcon
       set pot = 9900
     where usuario = 'CONV_EDM'
       and tip_suministro = 'SU001'
       and pot = 10;
  
    update sumcon
       set pot = 13200
     where usuario = 'CONV_EDM'
       and tip_suministro = 'SU001'
       and pot = 13;
  
    update sumcon
       set pot = 16500
     where usuario = 'CONV_EDM'
       and tip_suministro = 'SU001'
       and pot = 17;
  
    update sumcon
       set pot = 19800
     where usuario = 'CONV_EDM'
       and tip_suministro = 'SU001'
       and pot = 20;
  
    commit;
  end;

  --Adding logging info for conversion into SUMCON_LOG....
  insert into sumcon_log
    select usuario, trunc(sysdate), programa, nis_rad, sec_nis, s.f_mod_cont,
           'CL001'
      from sumcon s
     where not exists (select 0
              from sumcon_log
             where nis_rad = s.nis_rad
               and sec_nis = s.sec_nis);

  --Log end of running
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'ENDING', p_status => 'ENDING',
                        p_row_count => ll_commit);
  commit;
end conversion_sumcon;
/
