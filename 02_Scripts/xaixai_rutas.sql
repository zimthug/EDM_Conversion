
insert into rutas
  select 'CONV_EDM' usuario, trunc(sysdate) f_actual, 'CONV_EDM' programa,
         cod_unicom, decode(d.cod_mask, 1024, 10, 2048, 20, 4096, 30) ruta,
         decode(d.cod_mask, 2048, 'RU004', 'RU012') tip_ruta,
         'AG- ' || cod_unicom ||
          decode(d.cod_mask, 1024, ' (BT)', 2048, ' (PREP)', 4096, ' (MT)') desc_ruta,
         0 t_ruta, 0 ult_nif_selecc, 2 ind_asig_contrata, 0 cod_ctrat,
         d.cod_mask, 'LD001' tip_distrib, 0 ind_genweekends,
         0 ind_genholidays, 0 ind_geninoneday,
         to_date(29991231, 'yyyymmdd') f_expire, 'DM005' edm_code, 0 suffix
    from unicom u, (select distinct cod_mask from int_supply) d
   where u.cod_unicom in (7100, 7102, 7103);

declare
  ls_est_ruta    varchar2(5);
  lf_fecha_nulla date := to_date(29991231, 'yyyymmdd');
begin
  for i in 1 .. 12 loop
  
    if i > 7 then
      ls_est_ruta := 'EU001';
    else
      ls_est_ruta := 'EU004';
    end if;
  
    insert into ciclos_ruta
      select usuario, f_actual, programa, cod_unicom, ruta, i, 2014 anyo,
             ls_est_ruta, 0 nl_aus, 0 nl_an, 0 nl_ok, 0 nl_gen,
             to_date('201401' || lpad(i, 2, 0), 'yyyyddmm') f_iteor,
             last_day(to_date('201401' || lpad(i, 2, 0), 'yyyyddmm')) f_fteor,
             lf_fecha_nulla f_ireal, lf_fecha_nulla f_freal, 1 ind_lect_real,
             0 t_generado, 0 t_restante, 0 nl_estim, 0 nl_norealiz, 0 na_gen,
             0 na_ok, 0 na_aus, 0 na_an, 0 na_no_realiz, 0 na_estim,
             0 nc_gen, 0 nc_ok, 0 nc_aus, 0 nc_an, 0 nc_no_realiz,
             0 nc_estim
        from rutas;
  end loop;
end;

declare
  cursor lcur_route is
    select z.zona, z.descripcao, cod_unicom, s.cod_mask
      from edmaccess.zonas z, int_centre_unicom s
     where z.zona = s.centre
       and s.system_id = 2;

  cursor lcur_order(cls_centre in varchar2) is
    select s.nis_rad, s.nif, s.sec_nis, a.centre, a.client, s.cod_mask,
           s.f_alta, s.cod_unicom, o.no_da_instalacao
      from sumcon s, int_supply a, edmaccess.consumidores o
     where s.nis_rad = a.nis_rad
       and o.zona = cls_centre
       and o.zona = a.centre
       and o.no_da_instalacao = a.client
     order by o.no_da_instalacao;
  lf_ciclo       date;
  ll_day         number;
  ll_ruta        number;
  ll_mitin       number;
  ll_aol_fin     number;
  ll_cod_unicom  number;
  gls_usuario    varchar2(15) := 'CONV_EDM';
  gls_programa   varchar2(15) := 'CONV_EDM';
  glf_fechanulla date := to_date(29991231, 'yyyymmdd');
begin

  for lcur_route_rec in lcur_route loop
  
    ll_cod_unicom := lcur_route_rec.cod_unicom;
  
    if lcur_route_rec.cod_mask = 1024 then
      ll_ruta := 10;
    elsif lcur_route_rec.cod_mask = 2048 then
      ll_ruta := 20;
    elsif lcur_route_rec.cod_mask = 4096 then
      ll_ruta := 30;
    end if;
    select nvl(max(num_itin), 0) + 1 into ll_mitin from mitin;
    --where cod_unicom = ll_cod_unicom;
  
    insert into mitin
      (usuario, f_actual, programa, cod_unicom, ruta, num_itin, desc_itin,
       t_itin, nif_prim, nif_ult, ind_ubic_reubic, tip_distrib, f_expire,
       avg_read_time, transport_type, default_reader, cod_cnae, ind_proc)
    values
      (gls_usuario, trunc(sysdate), gls_programa, ll_cod_unicom, ll_ruta,
       ll_mitin, 'ZONA - ' || lcur_route_rec.zona, 0, 0, 0, 1, 'LD001',
       glf_fechanulla, 0, 'AM000', 0, 0, 0);
  
    --Put dummy cycles..................
    select rw
      into ll_day
      from (select rw
               from ((select rownum rw
                         from (select 1 from dual group by cube(1, 2, 3, 4, 5))
                        where rownum <= 28) order by dbms_random.random))
     where rownum <= 1;
    for i in 1 .. 12 loop
    
      lf_ciclo := to_date('2014' || lpad(i, 2, 0) || lpad(ll_day, 2, 0),
                          'yyyymmdd');
    
      insert into ciclos_itin
        (usuario, f_actual, programa, cod_unicom, ruta, num_itin, ciclo,
         est_itin, nl_aus, nl_an, nl_ok, nl_gen, f_lteor, f_gen, f_recep,
         f_lreal, f_trat, f_fact, cod_lector, accion, num_tpl, nl_estim,
         nl_norealiz, f_estim, ind_trat, read_time, na_gen, na_ok, na_aus,
         na_an, na_no_realiz, na_estim, nc_gen, nc_ok, nc_aus, nc_an,
         nc_no_realiz, nc_estim)
      values
        (gls_usuario, trunc(sysdate), gls_programa, ll_cod_unicom, ll_ruta,
         ll_mitin, i, 'IR005', 0, 0, 0, 0, lf_ciclo, glf_fechanulla,
         glf_fechanulla, glf_fechanulla, glf_fechanulla, glf_fechanulla, 0,
         0, 0, 0, 0, glf_fechanulla, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0);
    
    end loop;
  
    ll_aol_fin := 0;
  
    for lcur_order_rec in lcur_order(lcur_route_rec.zona) loop
    
      ll_aol_fin := ll_aol_fin + 1;
    
      begin
      
        insert into fincas_per_lect
          (usuario, f_actual, programa, nif, cod_unicom, ruta, num_itin,
           aol_fin, tip_per_lect, f_ureubi, cod_mask)
        values
          (gls_usuario, trunc(sysdate), gls_programa, lcur_order_rec.nif,
           lcur_order_rec.cod_unicom, ll_ruta, ll_mitin, ll_aol_fin, 'RU012',
           lcur_order_rec.f_alta, lcur_order_rec.cod_mask);
      
        update fincas
           set duplicador = duplicador || '(' ||
                            lcur_order_rec.no_da_instalacao || ')'
         where nif = lcur_order_rec.nif;
      
      exception
        when others then
          dbms_output.put_line(sqlerrm || ' -> ' || lcur_order_rec.nis_rad ||
                               '  -> ' || ll_aol_fin);
      end;
    
    end loop;
  
  end loop;
end;
/
