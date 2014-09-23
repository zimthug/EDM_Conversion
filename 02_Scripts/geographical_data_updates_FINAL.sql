declare
  cursor ix is
    select aa.*, cod_calle
      from (select co.no_do_contador, sp.centre, sp.client,
                    cn.boad_designacao, cn.boad_idarea, cn.bocl_nocontador,
                    cn.bobr_idbairro, nif, nis_rad
               from edmaccess.contador co, edmcamp.cadastramento_new cn,
                    int_supply sp
              where trim(ltrim(nvl(substr(co.no_do_contador, 1,
                                          instr(co.no_do_contador, '/') - 1),
                                   co.no_do_contador), '0')) =
                    trim(cn.bocl_nocontador)
                and sp.centre = to_char(co.zona)
                and sp.client = co.no_da_instalacao
                and boad_idarea = 3
             union
             select co.msno, sp.centre, sp.client, cn.boad_designacao,
                    cn.boad_idarea, cn.bocl_nocontador, cn.bobr_idbairro, nif,
                    nis_rad
               from edmeclipse.customer_data co, edmcamp.cadastramento_new cn,
                    int_supply sp
              where trim(ltrim(co.msno, '0')) = trim(cn.bocl_nocontador)
                and sp.centre = '999'
                and sp.client = co.msno
                and boad_idarea = 3) aa, tmp_xaixai_geo_new bb
     where aa.bobr_idbairro = bb.bobr_idbairro
       and nif is not null
       and 1 = 2
     order by cod_calle;
  ll_cod_local  number;
  ll_cod_unicom number;
  ll_cod_calle  number := 0;
begin
  for x in ix loop
  
    if ll_cod_calle != x.cod_calle then
      select cod_unicom
        into ll_cod_unicom
        from callejero
       where cod_calle = x.cod_calle;
    end if;
  
    update int_supply e
       set cod_calle = x.cod_calle, e.cod_unicom = ll_cod_unicom
     where centre = x.centre
       and client = x.client;
  
    update fincas e
       set cod_calle = x.cod_calle, e.cod_oficom = ll_cod_unicom,
           e.cod_centec = ll_cod_unicom
     where nif = x.nif;
  
    update sumcon
       set cod_unicom = decode(cod_mask, 4096, 1012, ll_cod_unicom)
     where nif = x.nif;
  
    update recibos
       set cod_unicom = decode(cod_mask, 4096, 1012, ll_cod_unicom)
     where nis_rad = x.nis_rad;
  
    ll_cod_calle := x.cod_calle;
  
  end loop;

  declare
    cursor iv_zona is
      select * from edmaccess.zonas;
  
    cursor ip_zona(ll_cod_zona in varchar2) is
      select *
        from int_supply
       where cod_calle = 0
         and centre = ll_cod_zona;
  begin
    select max(cod_local) into ll_cod_local from localidades;
  
    select max(cod_calle) into ll_cod_calle from callejero;
  
    for iv_rec in iv_zona loop
    
      ll_cod_local := ll_cod_local + 1;
      ll_cod_calle := ll_cod_calle + 1;
    
      insert into localidades
        select usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
               ll_cod_local,
               z.descripcao || ' (ZONA ' || z.zona || ')' nom_local,
               0 area_ejec, 1000 nas_code,
               z.descripcao || ' (ZONA ' || z.zona || ')' nom_local_arab
          from municipios m, edmaccess.zonas z
         where cod_munic = 1014
           and z.zona = iv_rec.zona;
    
      insert into callejero
        select usuario, f_actual, programa, ll_cod_calle, cod_prov,
               cod_depto, cod_munic, cod_local,
               z.descripcao || ' (ZONA ' || z.zona || ')' nom_calle,
               'TV008' tip_via, 7100 cod_unicom, 7100 cod_oficom,
               2 ind_urb_rur, 0 cod_post, 7100 cod_centec, 'TV008' tip_via2,
               1 nas_code,
               z.descripcao || ' (ZONA ' || z.zona || ')' nom_calle_arab,
               0 ifs_dep_code
          from localidades l, edmaccess.zonas z
         where cod_local = ll_cod_local
           and z.zona = iv_rec.zona;
    
      ll_cod_unicom := 7100;
    
      for ip in ip_zona(iv_rec.zona) loop
        update int_supply e
           set cod_calle = ll_cod_calle, e.cod_unicom = ll_cod_unicom
         where centre = ip.centre
           and client = ip.client;
      
        update fincas e
           set cod_calle = ll_cod_calle, e.cod_oficom = ll_cod_unicom,
               e.cod_centec = ll_cod_unicom
         where nif = ip.nif;
      
        update sumcon
           set cod_unicom = decode(cod_mask, 4096, 1012, ll_cod_unicom)
         where nif = ip.nif;
      
        update recibos
           set cod_unicom = decode(cod_mask, 4096, 1012, ll_cod_unicom)
         where nis_rad = ip.nis_rad;
      
      end loop;
    end loop;
  end;
  
end;
