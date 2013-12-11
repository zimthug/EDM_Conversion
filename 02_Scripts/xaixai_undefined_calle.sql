declare
  cursor ix is
    select distinct centre from int_supply where system_id = '02' and cod_calle is null;
  ll_area       number;
  ll_cod_depto  number;
  ll_cod_calle  number;
  ll_cod_unicom number;
  ll_cod_munic  number;
  ll_cod_local  number;
  ls_nom_munic  varchar2(30);
  ls_nom_local  varchar2(30);
begin

  ll_cod_unicom := 7101;

  select cod_depto into ll_cod_depto from deptos where nom_depto = 'GAZA';

  select max(cod_munic) + 1 into ll_cod_munic from municipios;

  select max(cod_local) + 1 into ll_cod_local from localidades;

  ls_nom_munic := 'UNDEFINED XAI-XAI';

  insert into municipios
    (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic, nom_munic,
     nas_code, nom_munic_arab)
  values
    ('CONV_EDM', trunc(sysdate), 'CONV_EDM', 1, ll_cod_depto, ll_cod_munic,
     ls_nom_munic, ' ', ls_nom_munic);

  ls_nom_local := ls_nom_munic;

  insert into localidades
    (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic, cod_local,
     nom_local, area_ejec, nas_code, nom_local_arab)
  values
    ('CONV_EDM', trunc(sysdate), 'CONV_EDM', 1, ll_cod_depto, ll_cod_munic,
     ll_cod_local, ls_nom_local, 0, ll_cod_local, ls_nom_local);

  select max(cod_calle) into ll_cod_calle from callejero;

  for x in ix loop
  
    ll_cod_calle := ll_cod_calle + 1;
  
    /*select cod_depto
     into ll_cod_depto
     from municipios
    where cod_munic =
          decode(ll_area, 1, ll_cod_munic_maputo, ll_cod_munic_matola);*/
  
    insert into callejero
      (usuario, f_actual, programa, cod_calle, cod_prov, cod_depto,
       cod_munic, cod_local, nom_calle, tip_via, cod_unicom, cod_oficom,
       ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code, nom_calle_arab,
       ifs_dep_code)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', ll_cod_calle, 1,
       ll_cod_depto, ll_cod_munic, ll_cod_local,
       'UNDEFINED CENTRE ' || x.centre, 'TV008', ll_cod_unicom,
       ll_cod_unicom, 1, ' ', ll_cod_unicom, ' ', ll_cod_calle,
       'UNDEFINED CENTRE ' || x.centre, 0);
  
    for k in (select o.rowid
                from int_supply o
               where (cod_unicom = 0 or cod_unicom is null)
                 and centre = x.centre
                 and system_id = '02') loop
    
      update int_supply
         set cod_calle = ll_cod_calle, cod_unicom = ll_cod_unicom
       where rowid = k.rowid;
    
    end loop;
  end loop;
end;

/*select * from municipios;

select * from localidades order by cod_local desc;

select * from callejero order by cod_local desc;
*/
