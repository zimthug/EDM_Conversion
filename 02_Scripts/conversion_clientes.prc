CREATE OR REPLACE PROCEDURE conversion_clientes is

  cursor lcur_clientes is
    select upper(nvl(ape1_cli, ' ')) ape1_cli,
           upper(nvl(ape2_cli, ' ')) ape2_cli,
           upper(nvl(nom_cli, ' ')) nom_cli, nuit,
           nvl(trim(cualif_cli), 'TT000') cualif_cli, email, telefone1,
           telefone2, centre, client, nif, f_baja, f_alta, tip_cli, tip_doc,
           doc_id, cgv_cli, cod_calle, num_puerta,
           upper(nvl(duplicador, ' ')) duplicador, conv_id, cod_unicom
      from int_supply
     where nif is not null
       and cod_cli is null;
  ll_num            number := 0;
  ll_commit         number := 0;
  ll_cod_cli        number := 0;
  ll_nrh            number := 0;
  ll_nrh_fav        number := 0;
  ll_nrh_pen        number := 0;
  ll_fax_cli        number := 0;
  ll_pers_contacto  number := 0;
  ll_employee       number := 0;
  ll_co_pais        varchar2(6) := 'PD047';
  ll_co_cond_fiscal varchar2(6) := 'FC540';
  ls_program_name   varchar2(15) := 'CP3_CLIENTES';
begin
  --select nvl(max(cod_emp), 0) into ll_num from personal;

  select run_id.nextval into conversion_pck.gll_run_id from dual;

  --Log first to begin the program
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'STARTING', p_status => 'STARTING',
                        p_row_count => 0);
  commit;

  for lcur_clientes_rec in lcur_clientes loop
    begin
    
      select sgc.cod_cli.nextval into ll_cod_cli from dual;
    
      if regexp_instr(lcur_clientes_rec.nuit, '[[:alpha:]]') > 0 or
         length(lcur_clientes_rec.nuit) > 14 then
        lcur_clientes_rec.nuit := ' ';
      end if;
    
      insert into intfopen.clientes
        (usuario, f_actual, programa, cod_cli, ape1_cli, ape2_cli, nom_cli,
         tfno_cli, cod_calle, num_puerta, duplicador, cgv_cli, doc_id,
         tip_doc, co_pais, tip_cli, f_alta, f_baja, nrh, nrh_fav, nrh_pen,
         fax_cli, pers_contacto, co_cond_fiscal, soundex_ap1, soundex_ap2,
         ref_dir, cualif_cli, num_dev_cheq, cant_letras_impagas, num_fiscal,
         ape1_cli_up, datos, cod_post, nif, tfno2_cli, datos2, est_cli,
         spec_signal, ape3_cli, ape1_cli_arab, ape2_cli_arab, ape3_cli_arab,
         nom_cli_arab, ape1_cli_arab_up, ind_cash_only, cod_rating, f_rating,
         passport_no, job_title, nif_work, f_birth, tfno3_cli, email,
         observaciones, password, f_cash_only, cod_supp, group_supp)
      values
        (conversion_pck.gls_programa, trunc(sysdate),
         conversion_pck.gls_programa, ll_cod_cli, lcur_clientes_rec.ape1_cli,
         lcur_clientes_rec.ape2_cli, lcur_clientes_rec.nom_cli,
         nvl(substr(lcur_clientes_rec.telefone1, 1, 12), ' '),
         lcur_clientes_rec.cod_calle, nvl(lcur_clientes_rec.num_puerta, 0),
         lcur_clientes_rec.duplicador, nvl(lcur_clientes_rec.cgv_cli, ' '),
         nvl(lcur_clientes_rec.doc_id, ' '), lcur_clientes_rec.tip_doc,
         ll_co_pais, nvl(lcur_clientes_rec.tip_cli, 'TC006'),
         lcur_clientes_rec.f_alta, lcur_clientes_rec.f_baja, ll_nrh,
         ll_nrh_fav, ll_nrh_pen, ll_fax_cli, ll_pers_contacto,
         ll_co_cond_fiscal, '  ', '  ', '  ', lcur_clientes_rec.cualif_cli,
         0, 0, nvl(lcur_clientes_rec.nuit, ' '), lcur_clientes_rec.ape1_cli,
         '/1/6/ / / / /6/MP006/', ' ', lcur_clientes_rec.nif,
         nvl(lcur_clientes_rec.telefone2, ' '), '/0/0/', 'EK001', 'SS000',
         ' ', lcur_clientes_rec.ape1_cli, lcur_clientes_rec.ape2_cli, ' ',
         substr(lcur_clientes_rec.nom_cli, 1, 25),
         lcur_clientes_rec.ape1_cli, 2, 'RL999', trunc(sysdate), ' ',
         'JT000', 0, to_date('19000101', 'YYYYMMDD'), ' ',
         nvl(lcur_clientes_rec.email, ' '), ' ', ' ',
         conversion_pck.glf_fechanulla, ' ', ' ');
    
      /* 20140305 => To be handled in BONIFICACIONES and at the level of Supply (CONVERSION_SUMCON) */
      /*
      If customer is employee add into PERSONAL. We should get the employee number from
      the mapping to be provided by EDM.
      */
      /* select count(*)
        into ll_employee
        from edmgalatee.client
       where conso in (select substr(obs_code, -4)
                         from int_map_codes
                        where code_type = 'TC000'
                          and cms_desc = 'EMPLOYEE')
         and centre = lcur_clientes_rec.centre
         and client = lcur_clientes_rec.client;
      
      if ll_employee > 0 then
      
        ll_num := ll_num + 1;
      
        insert into personal
          (usuario, f_actual, programa, cod_emp, ape1_emp, ape2_emp,
           nomb_emp, cod_unicom, tip_emp, f_alta, cod_ctrat, peso_emp,
           ind_disp, num_proxy_card, f_alta_card, doc_id, num_tpl, ape3_emp,
           ape1_emp_arab, ape2_emp_arab, ape3_emp_arab, nomb_emp_arab,
           nom_usr, est_emp, cod_cli)
        values
          (conversion_pck.gls_programa, trunc(sysdate),
           conversion_pck.gls_programa, ll_num, lcur_clientes_rec.ape1_cli,
           lcur_clientes_rec.ape2_cli, lcur_clientes_rec.nom_cli,
           lcur_clientes_rec.cod_unicom, 'PN900', lcur_clientes_rec.f_alta,
           0, 0, 1, ' ', lcur_clientes_rec.f_alta, ' ', 0, ' ',
           lcur_clientes_rec.ape1_cli, lcur_clientes_rec.ape2_cli, ' ',
           lcur_clientes_rec.nom_cli, lcur_clientes_rec.client, 'CF001',
           ll_cod_cli);
      
      end if;*/
    
      update int_supply
         set cod_cli = ll_cod_cli
       where conv_id = lcur_clientes_rec.conv_id;
    
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
                                    p_id_number => lcur_clientes_rec.conv_id);
        commit;
    end;
  end loop;

  update clientes
     set tip_doc = 'TD007', doc_id = num_fiscal
   where tip_cli <> 'TC001'
     and trim(num_fiscal) is not null;

  --RCH script for num_fiscal....
  declare
    cursor c1 is
      SELECT cod_cli, num_fiscal
        FROM clientes a
       WHERE LENGTH(TRANSLATE(a.num_fiscal, 'x0123456789', 'x')) IS NOT NULL;
  
    i             number := 1000000;
    lc_num_fiscal varchar(12) := ' ';
  
  begin
    execute immediate ('alter session set nls_date_format = ''yyyymmdd''');
  
    for rec in c1 loop
      lc_num_fiscal := '9999' || to_char(i);
      update clientes
         set num_fiscal = lc_num_fiscal
       where cod_cli = rec.cod_cli;
      i := i + 1;
    end loop;
    --commit;
  end;

  --Log end of running
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'ENDING', p_status => 'ENDING',
                        p_row_count => ll_commit);
  commit;

end conversion_clientes;
/
