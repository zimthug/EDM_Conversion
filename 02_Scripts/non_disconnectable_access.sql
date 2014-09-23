declare
  cursor ix is
    select * from edmaccess.non_disconnectable;
begin
  execute immediate ('alter session set nls_date_format = ''yyyymmdd''');
  for x in ix loop
    update cuentas_cu c
       set c.co_motnocort = 'NC002'
     where cod_cli =
           (select cod_cli
              from int_supply
             where centre = to_char(to_number(x.zona))
               and client = to_char(to_number(x.contrato)));
  
    update sumcon j
       set j.co_an_vip = 'VP001'
     where nis_rad =
           (select nis_rad
              from int_supply
             where centre = to_char(to_number(x.zona))
               and client = to_char(to_number(x.contrato)));
  end loop;
end;

/*select to_char(zona), to_char(to_number(contrato)) from edmaccess.non_disconnectable
minus
select centre, client from int_supply*/
