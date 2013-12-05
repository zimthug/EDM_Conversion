declare
  cursor ix is
    select *
      from (select f.nif, f.cod_mask cod_mask_premise,
                    r.cod_mask cod_mask_route, r.desc_ruta
               from fincas_per_lect f, mitin m, rutas r
              where f.num_itin = m.num_itin
                and m.ruta = r.ruta
                and m.cod_unicom = r.cod_unicom)
     where cod_mask_premise <> cod_mask_route
       and cod_mask_premise = 4096;
  ll_aol_fin number;
begin
  for x in ix loop
    update fincas_per_lect
       set num_itin =
            (select min(num_itin)
               from mitin
              where (cod_unicom, ruta) in
                    (select cod_unicom, ruta from rutas where cod_mask = 4096))
     where nif = x.nif;
  end loop;
end;

--select * from fincas_per_lect where nif = 69022211

/*
select m.*, r.cod_mask from mitin m, rutas r
 where m.cod_unicom = r.cod_unicom 
   and m.ruta = r.ruta
   and m.num_itin = 8
*/
