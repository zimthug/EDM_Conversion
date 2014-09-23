begin
  for x in (select f.cod_oficom, s.nif, s.cod_mask
              from fincas f, sumcon s
             where f.nif = s.nif) loop
  
    update sumcon
       set cod_unicom = decode(x.cod_mask, 4096, 1012, x.cod_oficom)
     where nif = x.nif;
  
    update recibos
       set cod_unicom = decode(x.cod_mask, 4096, 1012, x.cod_oficom)
     where nis_rad in (select nis_rad from sumcon where nif = x.nif);
  
    update cargvar
       set cod_unicom = decode(x.cod_mask, 4096, 1012, x.cod_oficom)
     where nis_rad in (select nis_rad from sumcon where nif = x.nif);
  
  end loop;
  commit;
end;
