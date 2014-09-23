CREATE OR REPLACE PROCEDURE conversion_fincas is
  cursor lcur_fincas is
    select *
      from int_supply
     where nif is null
       and cod_tar is not null
       and cod_calle > 0
       and cod_calle is not null
       and (est_sum = 'EC012' or
           (est_sum like 'EC02%' and imp_tot_rec <> 0))
     order by cod_calle;
  --type lt_calle_count is table of number index by varchar2(64);
  ll_num          number;
  ll_nif          number;
  ll_commit       number := 0;
  ll_cod_ca       number := 0;
  ls_cod_nas      varchar2(17);
  ls_numero_aux   varchar2(10);
  ls_program_name varchar2(15) := 'CP3_FINCAS';
  --lt_calle_rec    lt_calle_count;

  /*function get_cod_nas(pll_cod_calle number) return varchar2 is
    ll_num number;
    ls_var varchar2(17);
  begin
    ll_num := lt_calle_rec(pll_cod_calle) + 1;
    select '0000' || lpad((ll_num \*select count(*) from fincas where cod_calle = ca.cod_calle*\
                           ), 5, 0) || lpad(cod_calle, 4, 0) ||
            lpad(cod_local, 4, 0)
      into ls_var
      from callejero ca
     where cod_calle = pll_cod_calle;
  
    lt_calle_rec(pll_cod_calle) := ll_num;
  
    return ls_var;
  end get_cod_nas;*/

begin
  select run_id.nextval into conversion_pck.gll_run_id from dual;

  /*for lcur_pop_rec in (select c.cod_calle,
                              (select count(*)
                                  from fincas
                                 where cod_calle = c.cod_calle) cnt
                         from callejero c) loop
    lt_calle_rec(lcur_pop_rec.cod_calle) := lcur_pop_rec.cnt;
  end loop;*/

  --Log first to begin the program
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'STARTING', p_status => 'STARTING',
                        p_row_count => 0);
  commit;

  for lcur_fincas_rec in lcur_fincas loop
    begin
    
      select sgc.nif.nextval into ll_nif from dual;
    
      if ll_cod_ca = lcur_fincas_rec.cod_calle then
        ll_num := ll_num + 1;
      else
        select count(*) + 1
          into ll_num
          from fincas
         where cod_calle = lcur_fincas_rec.cod_calle;
      end if;
    
      /*select '0000' || lpad((ll_num), 5, 0) || lpad(cod_calle, 4, 0) ||
             lpad(cod_local, 4, 0)
       into ls_cod_nas
       from callejero ca
      where cod_calle = lcur_fincas_rec.cod_calle;*/
    
      ls_cod_nas := ll_nif;
    
      ls_numero_aux := substr(ls_cod_nas, 1, 10);
    
      ll_cod_ca := lcur_fincas_rec.cod_calle;
    
      if substr(lcur_fincas_rec.duplicador, 1, 1) <> '|' then
        lcur_fincas_rec.duplicador := '|' || lcur_fincas_rec.duplicador;
      end if;
    
      if substr(lcur_fincas_rec.acc_finca, 1, 1) <> '|' then
        lcur_fincas_rec.acc_finca := '|' || lcur_fincas_rec.acc_finca;
      end if;
    
      insert into intfopen.fincas
        (usuario, f_actual, programa, nif, cod_calle, num_puerta,
         duplicador, cod_oficom, acc_finca, est_fin, tip_fin, f_inst,
         est_inst, f_baja, f_rev, t_finca, t_cl_finca, t_finca_ant, ref_dir,
         numero_aux, cod_centec, cod_post, cod_cli, sec_cta, valor, valor1,
         cod, plot_num, nom_finca_arab, cod_cli_inh, ind_share, cod_nas,
         title_deed, plot_size, built_size, doc_id, tip_doc, f_commence,
         tip_interest, interest, f_issue_doc, gis_x, gis_y, cod_cenlec,
         datos, equipment_id, equipment_site)
      values
        (conversion_pck.gls_usuario, trunc(sysdate),
         conversion_pck.gls_programa, ll_nif, lcur_fincas_rec.cod_calle,
         nvl(lcur_fincas_rec.num_puerta, 9999), lcur_fincas_rec.duplicador,
         lcur_fincas_rec.cod_unicom, lcur_fincas_rec.acc_finca, 'EF003',
         lcur_fincas_rec.tip_fin, lcur_fincas_rec.f_alta, 'IE002',
         lcur_fincas_rec.f_baja, to_date(29991231, 'yyyymmdd'), 0, 0, 0,
         nvl(lcur_fincas_rec.ref_dir, ' '), ls_numero_aux,
         lcur_fincas_rec.cod_unicom, ' ', 0, 0, 0, 0,
         lcur_fincas_rec.tip_cod, 'Undefined', lcur_fincas_rec.duplicador, 0,
         0, ls_cod_nas, 'Undefined', 999999999999, 999999999999, 'Undefined',
         'DD001', to_date(19000101, 'yyyymmdd'), ' ', ' ',
         to_date(19000101, 'yyyymmdd'), nvl(lcur_fincas_rec.gis_x, 0),
         nvl(lcur_fincas_rec.gis_y, 0), lcur_fincas_rec.cod_unicom,
         '/1/3/2//WS999/', ' ', ' ');
    
      update int_supply
         set nif = ll_nif
       where conv_id = lcur_fincas_rec.conv_id;
    
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
                                    p_id_number => lcur_fincas_rec.conv_id);
    end;
  end loop;

  --Log end of running
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'ENDING', p_status => 'ENDING',
                        p_row_count => ll_commit);
  commit;

end conversion_fincas;
/
