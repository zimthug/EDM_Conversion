insert into callejero
select usuario, f_actual, programa, 10000 + zona cod_calle, cod_prov, cod_depto,
       cod_munic, cod_local, descripcao nom_calle, 'TV008' tip_via, 7100 cod_unicom, 7100 cod_oficom,
       1 ind_urb_rur, ' ' cod_post, 7100 cod_centec, 'TV008' tip_via2, 1000 + zona nas_code,  descripcao nom_calle_arab,
       0 ifs_dep_code
  from edmaccess.zonas, localidades l
 where l.cod_local = 1002;

insert into edmaccess.undefined_callejero_zona
select zona, 10000 + zona from edmaccess.zonas;
