declare
  /*
  * This is not the proper way to create reading routes and itineraries.
  * This is only done for the purposes of testing if the conversion has
  * all the required data.
  *
  */
  cursor lcur_route is
    select tournee, a.centre, cod_unicom
      from edmgalatee.ag a, int_centre_unicom u
     where tournee <> '000'
       and a.centre = u.centre
       and (a.centre, a.ag) in
           (select centre, client from int_supply where nis_rad is not null)
    --and cod_unicom <> 1026
     group by tournee, a.centre, cod_unicom
     order by cod_unicom;

  cursor lcur_order(cls_tournee in varchar2, cls_centre in varchar2) is
    select s.nis_rad, s.nif, s.sec_nis, a.centre, a.client, s.cod_mask,
           s.f_alta, s.cod_unicom, to_number(o.ordretournee)
      from sumcon s, int_supply a, edmgalatee.ag o
     where s.nis_rad = a.nis_rad
       and o.centre = cls_centre
       and o.tournee = cls_tournee
       and o.centre = a.centre
       and o.ag = a.client
     order by to_number(o.ordretournee);
  lf_ciclo       date;
  ll_day         number;
  ll_ruta        number;
  ll_mitin       number;
  ll_aol_fin     number;
  ll_cod_unicom  number;
  gll_run_id     number;
  ll_prev_unicom number := 0;
  gls_usuario    varchar2(15) := 'CONV_EDM';
  gls_programa   varchar2(15) := 'CONV_EDM';
  glf_fechanulla date := to_date(29991231, 'YYYYMMDD');
begin
  for lcur_route_rec in lcur_route loop
  
    ll_cod_unicom := lcur_route_rec.cod_unicom;
  
    select nvl(max(num_itin), 0) + 1 into ll_mitin from mitin;
    --where cod_unicom = ll_cod_unicom;
  
    if ll_cod_unicom != ll_prev_unicom then
    
      select nvl(max(ruta), 0) + 1
        into ll_ruta
        from rutas
       where cod_unicom = ll_cod_unicom;
    
      begin
        insert into rutas
          (usuario, f_actual, programa, cod_unicom, ruta, tip_ruta,
           desc_ruta, t_ruta, ult_nif_selecc, ind_asig_contrata, cod_ctrat,
           cod_mask, tip_distrib, ind_genweekends, ind_genholidays,
           ind_geninoneday, f_expire)
        values
          (gls_usuario, trunc(sysdate), gls_programa, ll_cod_unicom,
           ll_ruta, 'RU012', 'AREA - ' || ll_cod_unicom, 0, 0, 2, 0, 1024,
           'LD001', 0, 0, 0, glf_fechanulla);
      
      end;
      
    end if;
  
    insert into mitin
      (usuario, f_actual, programa, cod_unicom, ruta, num_itin, desc_itin,
       t_itin, nif_prim, nif_ult, ind_ubic_reubic, tip_distrib, f_expire,
       avg_read_time, transport_type, default_reader, cod_cnae, ind_proc)
    values
      (gls_usuario, trunc(sysdate), gls_programa, ll_cod_unicom, ll_ruta,
       ll_mitin, 'BOOK - ' || lcur_route_rec.tournee, 0, 0, 0, 1, 'LD001',
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
    
      lf_ciclo := to_date('2013' || lpad(i, 2, 0) || lpad(ll_day, 2, 0),
                          'yyyymmdd');
    
      if ll_cod_unicom != ll_prev_unicom then
        insert into ciclos_ruta
          (usuario, f_actual, programa, cod_unicom, ruta, ciclo, anyo,
           est_ci_ruta, nl_aus, nl_an, nl_ok, nl_gen, f_iteor, f_fteor,
           f_ireal, f_freal, ind_lect_real, t_generado, t_restante, nl_estim,
           nl_norealiz, na_gen, na_ok, na_aus, na_an, na_no_realiz, na_estim,
           nc_gen, nc_ok, nc_aus, nc_an, nc_no_realiz, nc_estim)
        values
          (gls_usuario, trunc(sysdate), gls_programa, ll_cod_unicom,
           ll_ruta, i, 2013, 'EU001', 0, 0, 0, 0, lf_ciclo, lf_ciclo,
           glf_fechanulla, glf_fechanulla, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0, 0, 0, 0);
      
      end if;
    
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
  
    for lcur_order_rec in lcur_order(lcur_route_rec.tournee,
                                     lcur_route_rec.centre) loop
    
      ll_aol_fin := ll_aol_fin + 1;
    
      begin
      
        insert into fincas_per_lect
          (usuario, f_actual, programa, nif, cod_unicom, ruta, num_itin,
           aol_fin, tip_per_lect, f_ureubi, cod_mask)
        values
          (gls_usuario, trunc(sysdate), gls_programa, lcur_order_rec.nif,
           lcur_order_rec.cod_unicom, ll_ruta, ll_mitin, ll_aol_fin, 'RU012',
           lcur_order_rec.f_alta, lcur_order_rec.cod_mask);
      
      exception
        when others then
          dbms_output.put_line(sqlerrm || ' -> ' || lcur_order_rec.nis_rad ||
                               '  -> ' || ll_aol_fin);
      end;
    
    end loop;
  
    ll_prev_unicom := ll_cod_unicom;
  
  end loop;
end;
