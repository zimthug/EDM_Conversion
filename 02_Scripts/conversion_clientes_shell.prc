create or replace procedure conversion_clientes is
  cursor lcur_clientes is
    select *
      from int_supply
     where nif is not null
       and cod_cli is null;
  ll_commit       number := 0;
  ls_program_name varchar2(15) := 'CP3_CLIENTES';
begin
  select run_id.nextval into conversion_pck.gll_run_id from dual;

  --Log first to begin the program
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'STARTING', p_status => 'STARTING',
                        p_row_count => 0);
  commit;

  for lcur_clientes_rec in lcur_clientes loop
    begin
    
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
    end;
  end loop;

  --Log end of running
  conversion_pck.logger(p_run_id => conversion_pck.gll_run_id,
                        p_program_name => ls_program_name,
                        p_message => 'ENDING', p_status => 'ENDING',
                        p_row_count => ll_commit);
  commit;

end conversion_clientes;
/
