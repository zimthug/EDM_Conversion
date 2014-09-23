create or replace procedure prc_code_unicom(pll_cod_unicom in number,
                                            pll_new_unicom in number,
                                            pls_nom_unicom in varchar2 default null) is
  cursor lcur_constraint is
    select *
      from all_constraints
     where constraint_type = 'R'
       and r_constraint_name in ('PK_UNICOM', 'PK_RUTAS');
  nom_unicom varchar2(20);
begin
  --First of all disable the foreign keys pointing to UNICOM
  for lcur_constraint_rec in lcur_constraint loop
    null;
    /*execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
    lcur_constraint_rec.table_name ||
    ' disable constraint ' ||
    lcur_constraint_rec.constraint_name);*/
  end loop;

  /*if trim(pls_nom_unicom) is not null then
    select nom_unicom
      into ls_nom_unicom
      from unicom
     where cod_unicom = pll_cod_unicom;
  end if;*/

  update unicom
     set cod_unicom = pll_new_unicom,
         nom_unicom = nvl(pls_nom_unicom, nom_unicom)
   where cod_unicom = pll_cod_unicom;

  update unicom
     set resp_unicom = pll_new_unicom
   where resp_unicom = pll_cod_unicom;

  update apa_almacenes
     set cod_almacen = pll_new_unicom
   where cod_almacen = pll_cod_unicom;

  update apa_almacenes
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update cms_giaf_location c
     set c.cms_cod_unicom = pll_new_unicom,
         c.cms_nom_unicom = pls_nom_unicom
   where c.cms_cod_unicom = pll_cod_unicom;

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
     set cod_unicom = pll_new_unicom
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

  update int_supply
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  update cargvar
     set cod_unicom = pll_new_unicom
   where cod_unicom = pll_cod_unicom;

  --Finally enable unicom constraints
  for lcur_constraint_rec in lcur_constraint loop
    null;
    /*execute immediate ('alter table ' || lcur_constraint_rec.owner || '.' ||
    lcur_constraint_rec.table_name ||
    ' disable constraint ' ||
    lcur_constraint_rec.constraint_name);*/
  end loop;

end prc_code_unicom;
/
