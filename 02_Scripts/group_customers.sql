declare
  cursor lcur_group is
    select sp.nis_rad, cl.conso, cl.nomabon, cod_cli, sec_cta
      from edmgalatee.client cl, int_supply sp
     where conso in ('0078', '0077', '0055', '0091')
       and cl.centre = sp.centre
       and cl.client = sp.client
       and sp.nis_rad is not null
     order by conso, sp.nis_rad;
  ll_gnis_rad number;
  ls_conso    varchar2(10) := ' ';
  ls_name     varchar2(60) := ' ';
begin
  for lcur_group_rec in lcur_group loop
    if ls_conso != lcur_group_rec.conso then
      if lcur_group_rec.conso = '0078' then
        ls_name := 'VODACOM';
      elsif lcur_group_rec.conso = '0077' then
        ls_name := 'MCEL';
      elsif lcur_group_rec.conso = '0055' then
        ls_name := 'EDUCAÇÃO';
      elsif lcur_group_rec.conso = '0091' then
        ls_name := 'POLÍCIA';
      end if;
    
      update clientes@cmsuat c
         set ape1_cli = ls_name, ape2_cli = ' ', ape3_cli = ' ',
             c.ape1_cli_up = ls_name, c.ape1_cli_arab = ls_name,
             c.ape2_cli_arab = ' ', c.ape3_cli_arab = ' ',
             c.ape1_cli_arab_up = ls_name
       where cod_cli = lcur_group_rec.cod_cli;
    
      select nis_rad
        into ll_gnis_rad
        from account_assoc@cmsuat
       where nis_rad_sub = lcur_group_rec.nis_rad;
    else    
      update account_assoc@cmsuat
         set f_anul = trunc(sysdate)
       where nis_rad_sub = lcur_group_rec.nis_rad;
    
      insert into account_assoc@cmsuat
        (usuario, f_actual, programa, nis_rad, nis_rad_sub, f_val, f_anul,
         perc_usage, f_last_bill, sec_nis_sub, sec_nis)
        select 'CONV_EDM' usuario, trunc(sysdate) f_actual,
               'CONV_EDM' programa, ll_gnis_rad, lcur_group_rec.nis_rad,
               trunc(sysdate) f_val, to_date(29991231, 'yyyymmdd') f_anul,
               perc_usage, f_last_bill, sec_nis_sub, sec_nis
          from account_assoc@cmsuat
         where nis_rad_sub = lcur_group_rec.nis_rad;
    
      update cuentas_cu@cmsuat
         set account_id = ll_gnis_rad
       where cod_cli = lcur_group_rec.cod_cli
         and sec_cta = lcur_group_rec.sec_cta;
    end if;
  
    ls_conso := lcur_group_rec.conso;
  
  end loop;
end;

/*
select * from account_assoc@cmsuat where nis_rad_sub in (200011621,
200011624,
200011764,
200012500,
200012525,
200012526,
200012527,
200012792,
200012821,
200012938,
200013101,
200013297
)
*/

/*
select sp.nis_rad, cl.conso, cl.nomabon, cod_cli, sec_cta, su.nis_rad global_nis_rad
      from edmgalatee.client cl, int_supply sp, account_assoc@cmsuat su
     where conso in ('0078', '0077', '0055', '0091')
       and cl.centre = sp.centre
       and cl.client = sp.client
       and sp.nis_rad is not null
       and sp.nis_rad = su.nis_rad_sub
       and sysdate between su.f_val and su.f_anul
     order by conso, sp.nis_rad;*/
