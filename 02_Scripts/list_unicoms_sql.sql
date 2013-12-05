select level, lpad('  ', 2 * (level - 1)) || nom_unicom nom_unicom,
       cod_unicom,
       (select nom_unicom from unicom where cod_unicom = u.resp_unicom) report_to,
       decode(u.ind_oc, 1, 'Yes', 'No') commercial,
       decode(u.ind_cl, 1, 'Yes', 'No') reading,
       decode(u.ind_ct, 1, 'Yes', 'No') technical, u.cod_mask
  from unicom u
 start with resp_unicom = 0 -- cod_unicom = 8000 
connect by prior cod_unicom = resp_unicom
