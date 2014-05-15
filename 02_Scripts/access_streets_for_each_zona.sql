declare
  cursor ix is
    select z.zona, upper(z.descripcão) name from edmaccess.zonas z;
  ll_cod_calle number;
  ll_cod_local number;
  ll_cod_prov  number := 1;
  ll_cod_depto number := 11;
  ll_cod_munic number := 113;
  ls_nom_local varchar2(30) := 'XAI-XAI';
begin
  select nvl(max(cod_calle), 1) into ll_cod_calle from callejero;

  select nvl(max(cod_local), 1) + 1 into ll_cod_local from localidades;

  insert into localidades
    (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic, cod_local,
     nom_local, area_ejec, nas_code, nom_local_arab)
    select usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
           ll_cod_local, ls_nom_local, 0, ll_cod_local, ls_nom_local
      from municipios
     where cod_munic = ll_cod_munic;

  for x in ix loop
  
    ll_cod_calle := ll_cod_calle + 1;
  
    insert into callejero
      (usuario, f_actual, programa, cod_calle, cod_prov, cod_depto,
       cod_munic, cod_local, nom_calle, tip_via, cod_unicom, cod_oficom,
       ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code, nom_calle_arab,
       ifs_dep_code)
      select usuario, f_actual, programa, ll_cod_calle, cod_prov, cod_depto,
             ll_cod_munic, ll_cod_local, x.name, tip_via, cod_unicom,
             cod_oficom, ind_urb_rur, cod_post, cod_centec, tip_via2,
             nas_code, x.name, ifs_dep_code
        from callejero
       where cod_calle = (select min(cod_calle)
                            from callejero
                           where cod_depto = ll_cod_depto);
  
    insert into edmaccess.undefined_callejero_zona
    values
      (x.zona, ll_cod_calle);
      
  end loop;
end;

/*create table edmaccess.undefined_callejero_zona
(
zona number not null primary key,
cod_calle number not null
)*/


--select * from edmaccess.undefined_callejero_zona
