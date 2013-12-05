select a.centre, count(*)
  from edmgalatee.client a, edmgalatee.abon b, edmgalatee.ag c
 where a.centre = b.centre
   and a.centre = c.centre
   and a.client = b.client
   and a.client = c.ag
   and a.ordre = b.ordre
   and exists (select 0
          from int_supply
         where centre = a.centre
           and client = a.client
           and ordre = a.ordre)
 group by a.centre;

select nvl(centre, 'Tariff Sub Total') centre, tarif as tariff_code,
       obs_desc tariff_desc, cnt as count_
  from (select a.centre, b.tarif, c.obs_desc, count(*) cnt
           from edmgalatee.client a, edmgalatee.abon b, int_map_tariffs c
          where a.centre = b.centre
            and a.client = b.client
            and a.ordre = b.ordre
            and b.tarif = substr(c.obs_tariff, 5)
            and exists (select 0
                   from int_supply
                  where centre = a.centre
                    and client = a.client
                    and ordre = a.ordre)
          group by rollup(a.centre), b.tarif, c.obs_desc);

--Converted
select tarif as tariff_code, obs_desc tariff_desc, cnt as count_, conv
  from (select a.centre, b.tarif, c.obs_desc, count(*) cnt,
                sum((select count(*)
                       from sumcon s, rel_nis_rutafol r
                      where r.nis_rad = s.nis_rad
                        and r.folio =
                            a.centre || '-' || a.client || '-' || a.ordre)) conv
           from edmgalatee.client a, edmgalatee.abon b, int_map_tariffs c
          where a.centre = b.centre
            and a.client = b.client
            and a.ordre = b.ordre
            and b.tarif = substr(c.obs_tariff, 5)
            and exists (select 0
                   from int_supply
                  where centre = a.centre
                    and client = a.client
                    and ordre = a.ordre)
          group by b.tarif, c.obs_desc);

--Premises by office
select u1.nom_unicom region, un.nom_unicom office, count(*)
  from fincas fi, unicom un, unicom u1
 where fi.cod_oficom = un.cod_unicom
   and un.resp_unicom = u1.cod_unicom
   and fi.programa = 'CONV_EDM'
 group by u1.nom_unicom, un.nom_unicom;

--Clients by type
select l.obj_text, t.libelle, count(*) cnt
  from clientes c, lang_dict_db l, edmgalatee.client e, int_supply s, edmgalatee.ta t
 where 'T.' || c.tip_cli = l.obj_key
   and lang_id = 1
   and s.centre = e.centre
   and s.client = e.client
   and s.ordre = e.ordre
   and s.cod_cli = c.cod_cli
   and lpad(e.conso, 6, 0) = t.code
   and t.num = '13'
   and c.programa = 'CONV_EDM'
 group by rollup(l.obj_text, t.libelle);
