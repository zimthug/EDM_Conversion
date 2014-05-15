declare
  cursor ix is
    select ap.nis_rad, ap.num_apa, ap.co_marca, ap.f_inst,
           (select min(f_lect)
               from apmedida_co
              where nis_rad = ap.nis_rad
                and num_apa = ap.num_apa
                and co_marca = ap.co_marca) f_lect
      from apmedida_ap ap
     where f_inst != (select min(f_lect)
                        from apmedida_co
                       where nis_rad = ap.nis_rad
                         and num_apa = ap.num_apa
                         and co_marca = ap.co_marca)
       and exists (select 0
              from apmedida_co
             where nis_rad = ap.nis_rad
               and num_apa = ap.num_apa
               and co_marca = ap.co_marca);
begin
  for x in ix loop
  
    update apmedida_ap
       set f_inst = x.f_lect
     where nis_rad = x.nis_rad
       and num_apa = x.num_apa
       and co_marca = x.co_marca;
  
    update apmedida_param
       set f_val = x.f_lect
     where num_apa = x.num_apa
       and co_marca = x.co_marca;
  
    update puntomed_param
       set f_val = x.f_lect
     where nis_rad = x.nis_rad
       and f_val > x.f_lect;
  
  end loop;
end;
/


declare
  cursor ix is
    select *
      from sumcon su
     where est_sum = 'EC012'
       and exists (select 0
              from account_assoc
             where nis_rad_sub = su.nis_rad
               and f_anul < sysdate);
  lf_date date := to_date(29991231, 'yyyymmdd');
begin
  for x in ix loop
  
    update account_assoc
       set f_anul = lf_date
     where nis_rad_sub = x.nis_rad;
  
    update sumcon set f_baja = lf_date where nis_rad = x.nis_rad;
  
  end loop;
end;
/
