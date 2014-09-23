declare
  cursor ix is
    select cod_cli, c.nuit as cod_emp
      from int_supply s, edmgalatee.client c
     where c.centre = s.centre
       and c.client = s.client
       and conso in (select substr(obs_code, -4)
                       from int_map_codes
                      where code_type = 'TC000'
                        and cms_desc = 'EMPLOYEE')
       and cod_cli is not null;
  ll        number;
  param_val owa.vc_arr;
begin
  ll := 999900000;

  for x in ix loop
  
    param_val(1) := 1;
    owa.init_cgi_env(param_val);
  
    if x.cod_emp is null then
      ll        := ll + 1;
      x.cod_emp := ll;
    end if;
  
    update clientes
       set num_fiscal = lpad(x.cod_emp, 9, 0), tip_doc = 'TD007',
           doc_id = lpad(x.cod_emp, 9, 0)
     where cod_cli = x.cod_cli;
  
    sgc.xml_api.addemployeebonus(p_nuit => lpad(x.cod_emp, 9, 0),
                                 p_empnumber => x.cod_emp,
                                 p_empstatus => 'E',
                                 p_start_date => 20010101,
                                 p_end_date => 29991231);
  end loop;
  --commit;
end;
/

