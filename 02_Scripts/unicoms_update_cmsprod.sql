declare
  cursor lcur_constraint is
    select *
      from all_constraints
     where constraint_type = 'R'
       and r_constraint_name in
           ('PK_UNICOM', 'PK_RUTAS', 'PK_CICLOS_RUTA', 'PK_MITIN');
  nom_unicom     varchar2(20);
  pll_cod_unicom number := 3610;
  pll_new_unicom number := 3602;
begin
  --First of all disable the foreign keys pointing to UNICOM
  for lcur_constraint_rec in lcur_constraint loop
    null;
    execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
                      lcur_constraint_rec.table_name ||
                      ' disable constraint ' ||
                      lcur_constraint_rec.constraint_name);
  end loop;

  UPDATE unicom SET cod_unicom = 3604 WHERE cod_unicom = 3641;
  UPDATE unicom SET cod_unicom = 3605 WHERE cod_unicom = 3605;
  UPDATE unicom SET cod_unicom = 3600 WHERE cod_unicom = 3601;
  UPDATE unicom SET cod_unicom = 3641 WHERE cod_unicom = 3642;
  UPDATE unicom SET cod_unicom = 3661 WHERE cod_unicom = 3661;
  UPDATE unicom SET cod_unicom = 3650 WHERE cod_unicom = 3650;
  UPDATE unicom SET cod_unicom = 3630 WHERE cod_unicom = 3611;
  UPDATE unicom SET cod_unicom = 3603 WHERE cod_unicom = 3602;
  UPDATE unicom SET cod_unicom = 3663 WHERE cod_unicom = 3663;
  UPDATE unicom SET cod_unicom = 3631 WHERE cod_unicom = 3612;
  UPDATE unicom SET cod_unicom = 3662 WHERE cod_unicom = 3662;
  UPDATE unicom SET cod_unicom = 3643 WHERE cod_unicom = 3640;
  UPDATE unicom SET cod_unicom = 3632 WHERE cod_unicom = 3613;
  UPDATE unicom SET cod_unicom = 3606 WHERE cod_unicom = 3660;
  UPDATE unicom SET cod_unicom = 3651 WHERE cod_unicom = 3651;
  UPDATE unicom SET cod_unicom = 3602 WHERE cod_unicom = 3610;

  update apa_almacenes
     set cod_almacen = pll_new_unicom
   where cod_almacen = pll_cod_unicom;

  update apa_almacenes
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update rutas
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update ciclos_ruta
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update mitin
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update ciclos_itin
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update fincas_per_lect
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update sumcon
     set cod_unicom = decode(cod_mask, 4096, 1012, pll_new_unicom)
   where cod_unicom = pll_cod_unicom;

  update recibos
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update fincas f
     set f.cod_oficom = pll_new_unicom, f.cod_centec = pll_new_unicom,
         f.cod_cenlec = pll_new_unicom
   where cod_oficom = pll_cod_unicom;

  update callejero c
     set cod_unicom = pll_new_unicom, c.cod_oficom = pll_new_unicom,
         c.cod_centec = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update cargvar
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  --Finally enable unicom constraints
  for lcur_constraint_rec in lcur_constraint loop
    null;
    execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
                      lcur_constraint_rec.table_name ||
                      ' disable constraint ' ||
                      lcur_constraint_rec.constraint_name);
  end loop;

end;
/

declare cursor lcur_constraint is
  select *
    from all_constraints
   where constraint_type = 'R'
     and r_constraint_name in
         ('PK_UNICOM', 'PK_RUTAS', 'PK_CICLOS_RUTA', 'PK_MITIN');
nom_unicom varchar2(20);
pll_cod_unicom number := 3641;
pll_new_unicom number := 3604;
begin
  --First of all disable the foreign keys pointing to UNICOM
  for lcur_constraint_rec in lcur_constraint loop
    null;
    execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
                      lcur_constraint_rec.table_name ||
                      ' disable constraint ' ||
                      lcur_constraint_rec.constraint_name);
  end loop;

  update apa_almacenes
     set cod_almacen = pll_new_unicom
   where cod_almacen = pll_cod_unicom;

  update apa_almacenes
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update rutas
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update ciclos_ruta
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update mitin
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update ciclos_itin
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update fincas_per_lect
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update sumcon
     set cod_unicom = decode(cod_mask, 4096, 1012, pll_new_unicom)
   where cod_unicom = pll_cod_unicom;

  update recibos
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update fincas f
     set f.cod_oficom = pll_new_unicom, f.cod_centec = pll_new_unicom,
         f.cod_cenlec = pll_new_unicom
   where cod_oficom = pll_cod_unicom;

  update callejero c
     set cod_unicom = pll_new_unicom, c.cod_oficom = pll_new_unicom,
         c.cod_centec = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update cargvar
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  --Finally enable unicom constraints
  for lcur_constraint_rec in lcur_constraint loop
    execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
                      lcur_constraint_rec.table_name ||
                      ' disable constraint ' ||
                      lcur_constraint_rec.constraint_name);
  end loop;

end;
/

update unicom v set cod_calle = (
  select max(cod_calle)
    from callejero)
   where cod_calle not in (select cod_calle from callejero);


update sucursales v
   set v.cod_calle =
        (select max(cod_calle) from callejero)
 where cod_calle not in (select cod_calle from callejero);

begin

  execute immediate ('alter sequence SGC.SEQ_REFERENCIA_EDM increment by 2799999 nocache');
  execute immediate ('select SGC.SEQ_REFERENCIA_EDM.nextval from dual');
  execute immediate ('alter sequence SGC.SEQ_REFERENCIA_EDM increment by 1 nocache');
  for x in (select *
              from sumcon
             where cod_mask != 2048
               and tip_suministro != 'SU900') loop
  
    update sumcon
       set num_ident_sipo = seq_referencia_edm.nextval
     where nis_rad = x.nis_rad;
  
  end loop;
  commit;
end;
/
