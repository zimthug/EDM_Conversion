declare
  cursor ix is
    select e.*, nis_rad, cod_cli, e.codigo cod_emp
      from edmaccess.employees e, int_supply s
     where e.zona = s.centre
       and e.mec = s.client
       and cod_cli is not null
    union
    select e.*, nis_rad, cod_cli, e.codigo cod_emp
      from edmaccess.employees e, int_supply s
     where e.contador = s.client
       and cod_cli is not null;
  ll        number;
  param_val owa.vc_arr;
begin
  ll := 999900000;

  for x in ix loop
  
    param_val(1) := 1;
    owa.init_cgi_env(param_val);
  
    --if x.cod_emp is null then
    ll        := ll + 1;
    x.cod_emp := ll;
    --end if;
  
    update clientes
       set num_fiscal = lpad(x.cod_emp, 9, 0), tip_doc = 'TD007',
           doc_id = lpad(x.cod_emp, 9, 0), tip_cli = 'TC006'
     where cod_cli = x.cod_cli;
  
    sgc.xml_api.addemployeebonus(p_nuit => lpad(x.cod_emp, 9, 0),
                                 p_empnumber => lpad(x.cod_emp, 9, 0),
                                 p_empstatus => 'E',
                                 p_start_date => 20010101,
                                 p_end_date => 29991231);
  end loop;
  --commit;
end;
/
