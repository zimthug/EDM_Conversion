declare
  cursor ix is
    select * from rutas where programa = 'CONV_EDM';

  cursor ik(pll_num_itin in number, pll_cod_mask in number) is
    select f.rowid
      from fincas_per_lect f
     where num_itin = pll_num_itin
       and exists (select 0
              from sumcon
             where nif = f.nif
               and cod_mask = pll_cod_mask
               and tip_suministro = 'SU001');

  ll_ruta     number;
  ll_cod_mask number;
  ll_num_itin number;
  ll_old_itin number;
begin

  select max(ruta) into ll_ruta from rutas;

  select max(num_itin) into ll_num_itin from mitin;

  for x in ix loop
    for i in 1 .. 2 loop
      if i = 1 then
        ll_cod_mask := 2048;
      else
        ll_cod_mask := 4096;
      end if;
      ll_ruta := ll_ruta + 1;
    
      insert into rutas
        select usuario, f_actual, programa, cod_unicom, ll_ruta, tip_ruta,
               desc_ruta, t_ruta, ult_nif_selecc, ind_asig_contrata,
               cod_ctrat, ll_cod_mask, tip_distrib, ind_genweekends,
               ind_genholidays, ind_geninoneday, f_expire, edm_code, suffix
          from rutas
         where ruta = x.ruta
           and cod_unicom = x.cod_unicom;
    
      insert into ciclos_ruta
        select usuario, f_actual, programa, cod_unicom, ll_ruta, ciclo, anyo,
               est_ci_ruta, nl_aus, nl_an, nl_ok, nl_gen, f_iteor, f_fteor,
               f_ireal, f_freal, ind_lect_real, t_generado, t_restante,
               nl_estim, nl_norealiz, na_gen, na_ok, na_aus, na_an,
               na_no_realiz, na_estim, nc_gen, nc_ok, nc_aus, nc_an,
               nc_no_realiz, nc_estim
          from ciclos_ruta
         where ruta = x.ruta
           and cod_unicom = x.cod_unicom;
    
      ll_num_itin := ll_num_itin + 1;
    
      select num_itin
        into ll_old_itin
        from mitin
       where ruta = x.ruta
         and cod_unicom = x.cod_unicom;
    
      insert into mitin
        select usuario, f_actual, programa, cod_unicom, ll_ruta, ll_num_itin,
               desc_itin, t_itin, nif_prim, nif_ult, ind_ubic_reubic,
               tip_distrib, f_expire, avg_read_time, transport_type,
               default_reader, cod_cnae, ind_proc
          from mitin
         where ruta = x.ruta
           and cod_unicom = x.cod_unicom;
    
      insert into ciclos_itin
        select usuario, f_actual, programa, cod_unicom, ll_ruta, ll_num_itin,
               ciclo, est_itin, nl_aus, nl_an, nl_ok, nl_gen, f_lteor, f_gen,
               f_recep, f_lreal, f_trat, f_fact, cod_lector, accion, num_tpl,
               nl_estim, nl_norealiz, f_estim, ind_trat, read_time, na_gen,
               na_ok, na_aus, na_an, na_no_realiz, na_estim, nc_gen, nc_ok,
               nc_aus, nc_an, nc_no_realiz, nc_estim
          from ciclos_itin
         where ruta = x.ruta
           and cod_unicom = x.cod_unicom;
    
      for k in ik(ll_old_itin, ll_cod_mask) loop
        
        update fincas_per_lect
           set cod_mask = ll_cod_mask, num_itin = ll_num_itin
         where rowid = k.rowid;
         
      end loop;
    end loop;
  end loop;
end;


/*select num_itin, s.cod_mask, count(*)
  from fincas_per_lect f, sumcon s
 where num_itin in (6, 21, 22)
   and f.nif = s.nif
   and s.tip_suministro = 'SU001'
 group by num_itin, s.cod_mask*/
 
/* select s.programa, s.cod_mask, r.cod_mask, tip_suministro, f.nif from rutas r, fincas_per_lect f, mitin m, sumcon s
  where r.ruta = m.ruta
  and r.cod_unicom = m.cod_unicom
  and m.num_itin = f.num_itin
  and r.cod_mask <> s.cod_mask
  and f.nif = s.nif
  and s.tip_suministro = 'SU001';*/
  
--select * from sumcon where nif in (69059723)
