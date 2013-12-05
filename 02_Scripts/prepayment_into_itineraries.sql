insert into rutas
select distinct ru.usuario, ru.f_actual, ru.programa, su.cod_unicom,
                nvl((select max(ruta) + 1
                    from rutas
                   where cod_unicom = su.cod_unicom), 1) ruta, tip_ruta,
                'PREPAGO - '||su.cod_unicom desc_ruta, t_ruta, ult_nif_selecc, ind_asig_contrata,
                cod_ctrat, su.cod_mask, tip_distrib, ind_genweekends,
                ind_genholidays, ind_geninoneday, f_expire, edm_code, suffix
  from sumcon su, rutas ru
 where nif not in (select nif from fincas_per_lect)
   and tip_suministro = 'SU001'
   and cod_tar = 'E10'
   and su.cod_unicom <> 1026
   and ru.rowid = (select min(rowid) from rutas);
--group by cod_unicom;

declare
  cursor ix is
    select * from rutas where desc_ruta like 'PREPAGO%';
  ll_aol      number;
  ll_num_itin number;
begin
  for x in ix loop
    insert into mitin
      select usuario, f_actual, programa, x.cod_unicom, x.ruta, num_itin + 1,
             x.desc_ruta, t_itin, nif_prim, nif_ult, ind_ubic_reubic,
             tip_distrib, f_expire, avg_read_time, transport_type,
             default_reader, cod_cnae, ind_proc
        from mitin
       where num_itin = (select max(num_itin) from mitin);
  
    ll_aol := 0;
  
    select max(num_itin) into ll_num_itin from mitin;
  
    for g in (select *
                from sumcon s
               where cod_mask = x.cod_mask
                 and tip_suministro = 'SU001'
                 and cod_unicom = x.cod_unicom
                 and not exists
               (select 0 from fincas_per_lect where nif = s.nif)) loop
    
      ll_aol := ll_aol + 1;
    
      insert into fincas_per_lect
        (usuario, f_actual, programa, nif, cod_unicom, ruta, num_itin,
         aol_fin, tip_per_lect, f_ureubi, cod_mask)
      values
        (x.usuario, x.f_actual, x.programa, g.nif, g.cod_unicom, x.ruta,
         ll_num_itin, ll_aol, x.tip_ruta, g.f_alta, x.cod_mask);
    
    end loop;
  end loop;
end;



select * from (
select nif, f.cod_mask a, r.cod_mask b from fincas_per_lect f, rutas r, mitin m
 where m.num_itin = f.num_itin and m.cod_unicom = r.cod_unicom
 and m.ruta = r.ruta
) where a <> b
