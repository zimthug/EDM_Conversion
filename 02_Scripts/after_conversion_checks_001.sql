update sumcon set tip_per_lect = 'RU004' where cod_mask = 2048;

update apmedida_ap
   set tip_per_lect = 'RU004'
 where nis_rad in (select nis_rad from sumcon where cod_mask = 2048);

commit;
