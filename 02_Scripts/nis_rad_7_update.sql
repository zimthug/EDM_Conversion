declare
  cursor ix is
    select cod_cli, nis_rad, substr(nis_rad, 1, 8) nis_rad_8
      from intfopen.sumcon
     where nis_rad like '7%';

begin
  for x in ix loop
  
    update sgc.account_assoc
       set nis_rad = x.nis_rad
     where nis_rad = x.nis_rad_8;
  
    update sgc.cuentas_cu
       set account_id = x.nis_rad
     where cod_cli = x.cod_cli;
  
    update sgc.rel_nis_rutafol
       set nis_rad = x.nis_rad
     where nis_rad = x.nis_rad_8;
     
  end loop;
end;
/
