--alter session enable parallel dml
declare
  cursor lcur_unicom is
    select *
      from unicom
     where cod_unicom in (select cod_unicom from callejero);
  type lcur_itinerary is record(
    nis_rad    number,
    nif        number,
    sec_nis    number,
    cod_mask   number,
    f_alta     date,
    cod_unicom number,
    aol_fin    number);
  lf_ciclo           date;
  ll_day             number;
  ll_aol_fin         number;
  ll_num_itin        number;
  ll_cod_mask        number;
  ls_tip_natur       varchar2(5);
  lcur_data          sys_refcursor;
  lcur_itinerary_rec lcur_itinerary;
  lfecha_nulla       date := to_date(29991231, 'yyyymmdd');

  function fnc_galatee_cursor(ll_cod_unicom in number,
                              ll_cod_mask   in number,
                              ls_book       in varchar2) return sys_refcursor is
    ls_return sys_refcursor;
  begin
    open ls_return for
      select /*+ parallel(4)*/s.nis_rad, s.nif, s.sec_nis, s.cod_mask, s.f_alta, s.cod_unicom,
             to_number(o.ordtour)
        from sumcon s, int_supply a, edmgalatee.ag o
       where s.nis_rad = a.nis_rad
         and s.cod_unicom = ll_cod_unicom
         and s.cod_mask = ll_cod_mask
         and o.tournee = ls_book
         and o.centre = a.centre
         and o.ag = a.client
       order by to_number(o.ordtour);
    return ls_return;
  
  end fnc_galatee_cursor;

  function fnc_access_cursor(ll_cod_unicom in number,
                             ll_cod_mask   in number,
                             ls_book       in varchar2) return sys_refcursor is
    ls_return sys_refcursor;
  begin
    open ls_return for
      select s.nis_rad, s.nif, s.sec_nis, s.cod_mask, s.f_alta, s.cod_unicom,
             to_number(o.no_da_instalacao)
        from sumcon s, int_supply a, edmaccess.consumidores o
       where s.nis_rad = a.nis_rad
         and s.cod_unicom = ll_cod_unicom
         and s.cod_mask = ll_cod_mask
         and to_char(o.zona) = ls_book
         and o.zona = a.centre
         and o.no_da_instalacao = a.client
       order by to_number(o.instalacao);
    return ls_return;
  
  end fnc_access_cursor;

  function fnc_eclipse_cursor(ll_cod_unicom in number,
                              ll_cod_mask   in number) return sys_refcursor is
    ls_return sys_refcursor;
  begin
    open ls_return for
      select s.nis_rad, s.nif, s.sec_nis, s.cod_mask, s.f_alta, s.cod_unicom,
             nis_rad ordre
        from sumcon s
       where s.cod_unicom = ll_cod_unicom
         and s.cod_mask = ll_cod_mask
       order by nis_rad;
    return ls_return;
  
  end fnc_eclipse_cursor;

begin
  select nvl(max(num_itin), 10) into ll_num_itin from mitin;

  /*for lcur_unicom_rec in lcur_unicom loop
    for i in 1 .. 3 loop
    
      if i = 1 then
        ll_cod_mask  := 1024;
        ls_tip_natur := 'RU012';
      elsif i = 2 then
        ll_cod_mask  := 2048;
        ls_tip_natur := 'RU004';
      elsif i = 3 then
        ll_cod_mask  := 4096;
        ls_tip_natur := 'RU012';
      end if;
    
      insert into rutas
        (usuario, f_actual, programa, cod_unicom, ruta, tip_ruta, desc_ruta,
         t_ruta, ult_nif_selecc, ind_asig_contrata, cod_ctrat, cod_mask,
         tip_distrib, ind_genweekends, ind_genholidays, ind_geninoneday,
         f_expire, edm_code, suffix)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_unicom_rec.cod_unicom,
         i * 10, ls_tip_natur, 'AGENCIA -' || lcur_unicom_rec.cod_unicom, 0,
         0, 2, 0, ll_cod_mask, 'LD001', 0, 0, 0, lfecha_nulla, 'DM001', 0);
    
      if i != 2 then
        for k in 1 .. 12 loop
          insert into ciclos_ruta
            (usuario, f_actual, programa, cod_unicom, ruta, ciclo, anyo,
             est_ci_ruta, nl_aus, nl_an, nl_ok, nl_gen, f_iteor, f_fteor,
             f_ireal, f_freal, ind_lect_real, t_generado, t_restante,
             nl_estim, nl_norealiz, na_gen, na_ok, na_aus, na_an,
             na_no_realiz, na_estim, nc_gen, nc_ok, nc_aus, nc_an,
             nc_no_realiz, nc_estim)
          values
            ('CONV_EDM', trunc(sysdate), 'CONV_EDM',
             lcur_unicom_rec.cod_unicom, i * 10, k, 2014, 'EU001', 0, 0, 0,
             0, to_date(201401 || lpad(k, 2, 0), 'yyyyddmm'),
             last_day(to_date(201401 || lpad(k, 2, 0), 'yyyyddmm')),
             lfecha_nulla, lfecha_nulla, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0);
        
        end loop;
      end if;
    end loop;
  
  end loop;*/
  declare
    cursor lcur_route is
      select distinct tournee, ag.centre, su.cod_unicom, su.cod_mask,
                      ru.ruta, '01' system_id
        from edmgalatee.ag ag, int_supply sp, sumcon su, rutas ru
       where tournee <> '000'
         and ag.centre = sp.centre
         and ag.ag = sp.client
         and sp.nis_rad = su.nis_rad
         and su.cod_unicom = ru.cod_unicom
         and su.cod_mask = ru.cod_mask
      union
      select distinct to_char(cs.zona) tournee, to_char(cs.zona) centre,
                      su.cod_unicom, ru.cod_mask, ru.ruta, '02' system_id
        from edmaccess.consumidores cs, int_supply sp, sumcon su, rutas ru
       where cs.zona = sp.centre
         and cs.no_da_instalacao = sp.client
         and sp.nis_rad = su.nis_rad
         and su.cod_unicom = ru.cod_unicom
         and su.cod_mask = ru.cod_mask
      union
      select distinct 'PREPAGO' tournee, 'PREPAGO' centre, su.cod_unicom,
                      ru.cod_mask, ru.ruta, '03' system_id
        from sumcon su, rutas ru
       where su.nis_rad = su.nis_rad
         and su.cod_unicom = ru.cod_unicom
         and su.cod_mask = ru.cod_mask
         and su.cod_mask = 2048;
  begin
    for lcur_route_rec in lcur_route loop
    
      ll_num_itin := ll_num_itin + 1;
    
      insert into mitin
        (usuario, f_actual, programa, cod_unicom, ruta, num_itin, desc_itin,
         t_itin, nif_prim, nif_ult, ind_ubic_reubic, tip_distrib, f_expire,
         avg_read_time, transport_type, default_reader, cod_cnae, ind_proc)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_route_rec.cod_unicom,
         lcur_route_rec.ruta, ll_num_itin,
         'BOOK - ' || lcur_route_rec.tournee, 0, 0, 0, 1, 'LD001',
         lfecha_nulla, 0, 'AM000', 0, 0, 0);
    
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
          ('CONV_EDM', trunc(sysdate), 'CONV_EDM',
           lcur_route_rec.cod_unicom, lcur_route_rec.ruta, ll_num_itin, i,
           'IR005', 0, 0, 0, 0, lf_ciclo, lfecha_nulla, lfecha_nulla,
           lfecha_nulla, lfecha_nulla, lfecha_nulla, 0, 0, 0, 0, 0,
           lfecha_nulla, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      end loop;
    
      if lcur_route_rec.system_id = '01' then
        lcur_data := fnc_galatee_cursor(lcur_route_rec.cod_unicom,
                                        lcur_route_rec.cod_mask,
                                        lcur_route_rec.tournee);
      elsif lcur_route_rec.system_id = '02' then
        lcur_data := fnc_access_cursor(lcur_route_rec.cod_unicom,
                                       lcur_route_rec.cod_mask,
                                       lcur_route_rec.tournee);
      else
        lcur_data := fnc_eclipse_cursor(lcur_route_rec.cod_unicom,
                                        lcur_route_rec.cod_mask);
      end if;
    
      ll_aol_fin := 0;
    
      loop
        fetch lcur_data
          into lcur_itinerary_rec;
        exit when lcur_data%notfound;
      
        if lcur_itinerary_rec.cod_mask != 2048 then
          ls_tip_natur := 'RU012';
        end if;
      
        ll_aol_fin := ll_aol_fin + 1;
      
        begin
          insert into fincas_per_lect
            (usuario, f_actual, programa, nif, cod_unicom, ruta, num_itin,
             aol_fin, tip_per_lect, f_ureubi, cod_mask)
          values
            ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_itinerary_rec.nif,
             lcur_itinerary_rec.cod_unicom, lcur_route_rec.ruta, ll_num_itin,
             ll_aol_fin, ls_tip_natur, lcur_itinerary_rec.f_alta,
             lcur_itinerary_rec.cod_mask);
        exception
          when dup_val_on_index then
            null;
        end;
      
      end loop;
      close lcur_data;
      insert into tmp_done values (sysdate);
      commit;
    end loop;
  end;
  insert into fincas_per_lect
    select 'CONV_EDM', f_actual, 'CONV_EDM', nif, cod_unicom, 0, 0, 0,
           decode(cod_mask, 2048, 'RU004', 'RU012'), lfecha_nulla, cod_mask
      from sumcon s
     where not exists (select 0 from fincas_per_lect where nif = s.nif);
  commit;
end;

/*

select * from rutas;

select * from ciclos_ruta;

select * from mitin;

select * from ciclos_itin;

select * from fincas_per_lect;

*/
