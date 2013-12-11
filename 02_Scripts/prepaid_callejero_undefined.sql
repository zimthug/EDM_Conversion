insert into callejero
  select usuario, f_actual, programa,
         (select max(cod_calle) + 1 from callejero) cod_calle, cod_prov,
         cod_depto, cod_munic, cod_local,
         'UNDEFINED MACHAVA PREPAGO' nom_calle, tip_via, cod_unicom,
         cod_oficom, ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code,
         'UNDEFINED MACHAVA PREPAGO' nom_calle_arab, ifs_dep_code
    from callejero
   where nom_calle like 'UNDEFINED CENTRE 050';

update int_supply
   set (cod_calle, cod_unicom) =
        (select cod_calle, cod_unicom
           from callejero
          where nom_calle = 'UNDEFINED MACHAVA PREPAGO')
 where (cod_unicom = 0 or cod_unicom is null)
   and duplicador like '%MACHAVA%'
   and system_id = '03';

insert into callejero
  select usuario, f_actual, programa,
         (select max(cod_calle) + 1 from callejero) cod_calle, cod_prov,
         cod_depto, cod_munic, cod_local,
         'UNDEFINED MATOLA PREPAGO' nom_calle, tip_via, cod_unicom,
         cod_oficom, ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code,
         'UNDEFINED MATOLA PREPAGO' nom_calle_arab, ifs_dep_code
    from callejero
   where nom_calle like 'UNDEFINED CENTRE 040';

update int_supply
   set (cod_calle, cod_unicom) =
        (select cod_calle, cod_unicom
           from callejero
          where nom_calle = 'UNDEFINED MATOLA PREPAGO')
 where (cod_unicom = 0 or cod_unicom is null)
   and duplicador like '%MATOLA%'
   and system_id = '03';

insert into callejero
  select usuario, f_actual, programa,
         (select max(cod_calle) + 1 from callejero) cod_calle, cod_prov,
         cod_depto, cod_munic, cod_local,
         'UNDEFINED MAPUTO PREPAGO' nom_calle, tip_via, cod_unicom,
         cod_oficom, ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code,
         'UNDEFINED MAPUTO PREPAGO' nom_calle_arab, ifs_dep_code
    from callejero
   where nom_calle like 'UNDEFINED CENTRE 010';

update int_supply
   set (cod_calle, cod_unicom) =
        (select cod_calle, cod_unicom
           from callejero
          where nom_calle = 'UNDEFINED MAPUTO PREPAGO')
 where (cod_unicom = 0 or cod_unicom is null)
   and system_id = '03';
