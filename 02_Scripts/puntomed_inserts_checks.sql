declare
  cursor ix is
  
    select *
      from sumcon
     where nis_rad in (select nis_rad
                         from sumcon
                        where tip_suministro != 'SU900'
                       minus
                       select nis_rad
                         from puntomed_param);
  ls_tip_pm varchar2(5);
begin
  for x in ix loop
    if x.cod_tar in ('E05', 'E06', 'E08') then
      ls_tip_pm := 'MB500';
    else
      ls_tip_pm := 'MB501';
    end if;
  
    insert into puntomed
      (usuario, f_actual, programa, nif_pm, cgv_pm, aol_pm, acc_pm, sec_pm)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.nif, 0, 1, 'AP017', 1);
  
    insert into puntomed_param
      (usuario, f_actual, programa, nis_rad, sec_apa, f_val, f_anul,
       nif_apa, sec_pm, tip_fase, tip_tension, tip_pm, observacion, aol_apa,
       num_id, valor, porc_csmo, ind_estm, valor1, valor2, datos)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.nis_rad, 1, x.f_alta,
       to_date(29991231, 'yyyymmdd'), x.nif, 1, x.tip_fase, x.tip_tension,
       ls_tip_pm, ' ', 10, 'AM000', 0, 0, 2, 0, 0, '/0/0/');
  
  end loop;
end;

/*update puntomed_param set tip_pm = 'MB500' where (nis_rad) in
(select nis_rad from sumcon where cod_tar in ('E05', 'E06', 'E08'))*/
