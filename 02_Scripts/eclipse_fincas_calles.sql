declare
  ll_cod_nas   number;
  ll_cod_local number;
  ll_cod_calle number;
  ls_district  varchar2(60) := ' ';
begin
  select max(cod_calle) into ll_cod_calle from callejero;

  for x in (select d.rowid, d.*, m.cod_munic cod_munices,
                   l.cod_local cod_locales
              from dg_ruas d, municipios m, localidades l
             where trim(upper(d.district)) = trim(upper(m.nom_munic))
               and m.cod_munic = l.cod_munic
            --and bomr_idmorada = 14
             order by district) loop
  
    /*if ls_district != x.district then
    
      if x.district = 'KaMpumo' then
        ll_cod_local := 1001;
      else
      
        select max(cod_local) + 1, max(to_number(nas_code)) + 1
          into ll_cod_local, ll_cod_nas
          from localidades;
      
        insert into localidades
          (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
           cod_local, nom_local, area_ejec, nas_code, nom_local_arab)
        values
          ('CONV_EDM', trunc(sysdate), 'CONV_EDM', 1, 10, x.cod_munices,
           ll_cod_local, 'Maputo Cidade', 0, ll_cod_nas, 'Maputo Cidade');
      end if;
    end if;*/
  
    ll_cod_local := x.cod_locales;
  
    ll_cod_calle := ll_cod_calle + 1;
  
    insert into callejero
      (usuario, f_actual, programa, cod_calle, cod_prov, cod_depto,
       cod_munic, cod_local, nom_calle, tip_via, cod_unicom, cod_oficom,
       ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code, nom_calle_arab,
       ifs_dep_code)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', ll_cod_calle, 1, 10,
       x.cod_munices, ll_cod_local, x.bomr_designacao, 'TV002', x.cod_unicom,
       x.cod_unicom, 1, ' ', x.cod_unicom, ' ', '0000', x.bomr_designacao, 0);
  
    update dg_ruas set cod_calle = ll_cod_calle where rowid = x.rowid;
  
    ls_district := x.district;
  
  end loop;
end;

--select * from call
--select * from callejero where trim(nom_calle) = 'Eduardo Mondlane';

declare
  cursor ix is
    select msno, bocl_nosaida, cn.bomr_idmorada, bocl_ycoord, bocl_xcoord,
           bodt_designacao, ru.cod_calle, nif
      from edmeclipse.customer_data cs, edmcamp.cadastramento_new cn,
           dg_ruas ru, int_supply sp
     where cs.msno = lpad(cn.bocl_nocontador, 11, 0)
       and cn.bomr_idmorada = ru.bomr_idmorada
       and client = msno
       and nif is not null;
begin
  for x in ix loop
    update fincas f
       set cod_calle = x.cod_calle, f.gis_x = x.bocl_xcoord,
           f.gis_y = x.bocl_ycoord
     where nif = x.nif;
  end loop;
end;
