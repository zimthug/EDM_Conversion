declare
  cursor lcur_mitin is
    select * from edmaccess.xaixai_itins;

  cursor lcur_itinerary(pll_num_itin in number, pll_limit in number) is
    select *
      from (select ex.*, nif, cod_mask, sp.f_alta
               from edmaccess.xaixai_itins_meters ex, int_supply sp
              where itinerary = pll_num_itin
                and ex.zona = sp.centre
                and ex.instalacao = sp.client
                and sp.nis_rad is not null
                and not exists
              (select nif from fincas_per_lect where nif = sp.nif)
              order by seq_id)
     where rownum <= pll_limit;

  ll_cnt        number := 0;
  ll_zop        number := 0;
  ll_ruta       number := 0;
  ll_aol_fin    number := 0;
  ll_num_itin   number := 99;
  ls_desc_itin  varchar2(30);
  lf_fechanulla date := to_date(29991231, 'yyyymmdd');
begin
  for lcur_mitin_rec in lcur_mitin loop
  
    ll_ruta := 10;
  
    if ll_zop = lcur_mitin_rec.zona then
      ll_cnt := nvl(ll_cnt, 0) + 1;
    else
      ll_cnt := null;
    end if;
  
    select z.descripcao || ' '|| ll_cnt
      into ls_desc_itin
      from edmaccess.zonas z
     where zona = lcur_mitin_rec.zona;
  
    ll_num_itin := ll_num_itin + 1;
  
    insert into mitin
      (usuario, f_actual, programa, cod_unicom, ruta, num_itin, desc_itin,
       t_itin, nif_prim, nif_ult, ind_ubic_reubic, tip_distrib, f_expire,
       avg_read_time, transport_type, default_reader, cod_cnae, ind_proc)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_mitin_rec.num_mrsp,
       ll_ruta, ll_num_itin, trim(ls_desc_itin), 0, 0, 0, 1, 'LD001',
       lf_fechanulla, 0, 'AM000', 0, 0, 0);
  
    for ciclo in 1 .. 12 loop
    
      insert into ciclos_itin
        (usuario, f_actual, programa, cod_unicom, ruta, num_itin, ciclo,
         est_itin, nl_aus, nl_an, nl_ok, nl_gen, f_lteor, f_gen, f_recep,
         f_lreal, f_trat, f_fact, cod_lector, accion, num_tpl, nl_estim,
         nl_norealiz, f_estim, ind_trat, read_time, na_gen, na_ok, na_aus,
         na_an, na_no_realiz, na_estim, nc_gen, nc_ok, nc_aus, nc_an,
         nc_no_realiz, nc_estim)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_mitin_rec.num_mrsp,
         ll_ruta, ll_num_itin, ciclo, 'IR005', 0, 0, 0, 0,
         lcur_mitin_rec.previsao_de_leitura, lf_fechanulla, lf_fechanulla,
         lf_fechanulla, lf_fechanulla, lf_fechanulla, 0, 0, 0, 0, 0,
         lf_fechanulla, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    
    end loop;
  
    ll_zop := lcur_mitin_rec.zona;
  
    ll_aol_fin := 0;
  
    for lcur_itinerary_rec in lcur_itinerary(lcur_mitin_rec.zona,
                                             lcur_mitin_rec.instalacoes) loop
    
      ll_aol_fin := ll_aol_fin + 1;
    
      insert into fincas_per_lect
        (usuario, f_actual, programa, nif, cod_unicom, ruta, num_itin,
         aol_fin, tip_per_lect, f_ureubi, cod_mask)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_itinerary_rec.nif,
         lcur_mitin_rec.num_mrsp, ll_ruta, ll_num_itin, ll_aol_fin, 'RU012',
         lcur_itinerary_rec.f_alta, 1024);
    
    end loop;
    dbms_output.put_line(ll_num_itin || '  ' || ll_aol_fin);
  end loop;

end;

/*
select m.num_itin, m.desc_itin, count(*) from fincas_per_lect f, mitin m
where f.num_itin = m.num_itin
group by m.desc_itin, m.num_itin;
*/
