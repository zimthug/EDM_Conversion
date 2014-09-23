select agencia, cms_municipio_code, municipio, taxa_lixo, cms_bairro_code, bairro, cms_street_code, "STREET/BAIRRO", via_type from
(select l.cod_prov cms_province_code, nom_prov province,
       l.cod_depto cms_district_code, nom_depto district,
       l.cod_munic cms_municipio_code, nom_munic municipio,
       l.cod_local cms_bairro_code, nom_local bairro,
       c.cod_calle cms_street_code, nom_calle "STREET/BAIRRO",
       obj_text via_type, nom_unicom agencia,
       decode((select count(*)
                 from municipios_lixo
                where cod_munic = l.cod_local), 1, 'YES', 'NO') taxa_lixo
  from provincias p, deptos d, municipios m, localidades l, callejero c,
       lang_dict_db z, unicom u
 where p.cod_prov = d.cod_prov
   and d.cod_depto = m.cod_depto
   and m.cod_munic = l.cod_munic
   and l.cod_local = c.cod_local
   and z.obj_key = 'T.' || c.tip_via
   and z.lang_id = 1
   and c.cod_unicom = u.cod_unicom
 order by 2, 4, 6, 8, 9)
