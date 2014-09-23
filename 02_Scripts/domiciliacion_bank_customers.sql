--alter session set nls_date_format = 'yyyymmdd'
declare
  cursor lcur_main is
    select s.centre, s.client, s.ordre, compte, c.banque, b.libelle, nis_rad,
           cod_cli
      from edmgalatee.client c, edmgalatee.bank b, int_supply s
     where modep = 1
       and c.banque = b.banque
       and b.banque in ('000109', '000009')
       and c.centre = s.centre
       and c.client = s.client
       and c.ordre = s.ordre
       and nis_rad is not null;
  ll_cod_mask     number;
  ll_cod_agencia  number := 1008;
  ll_cod_sucursal number := 8001;
begin
  for lcur_main_rec in lcur_main loop
    update cuentas_cu
       set tip_env = 'TE100'
     where cod_cli = lcur_main_rec.cod_cli;
  
    select cod_mask
      into ll_cod_mask
      from sumcon
     where nis_rad = lcur_main_rec.nis_rad;
  
    insert into domiciliacion
      (usuario, f_actual, programa, cod_agencia, cod_sucursal, tip_cencobro,
       cod_cli, sec_cta, f_alta_dom, f_act_est, num_dev_dom, sec_dom,
       num_cta_dom, est_dom, desc_cuenta, dia_envio, cod_mask, cod_mask_ant,
       datos)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', ll_cod_agencia,
       ll_cod_sucursal, 'CC001', lcur_main_rec.cod_cli, 1, trunc(sysdate),
       trunc(sysdate), 0, 1, lcur_main_rec.compte, 'ED002', ' ', 0,
       ll_cod_mask, 0, '/0/0/');
  end loop;
end;
