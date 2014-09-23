declare
  ll_dup        number := 0;
  ll_cod_calle  number := 0;
  ll_num_puerta number := 0;
  ls_duplicador varchar2(90) := ' ';
begin
  for x in (select *
              from fincas
             where (duplicador, cod_calle, num_puerta) in
                   (select duplicador, cod_calle, num_puerta
                      from fincas
                     group by duplicador, cod_calle, num_puerta
                    having count(*) > 1)
             order by duplicador, cod_calle, num_puerta) loop
  
    if ll_num_puerta = x.num_puerta and ll_cod_calle = x.cod_calle and
       ls_duplicador = x.duplicador then
      ll_dup := ll_dup + 1;
      update fincas set num_puerta = ll_dup where nif = x.nif;
    else
      ll_dup := 0;
    end if;
    ll_num_puerta := x.num_puerta;
    ll_cod_calle  := x.cod_calle;
    ls_duplicador := x.duplicador;
  end loop;
end;
