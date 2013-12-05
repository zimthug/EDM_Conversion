select area "Area", received "Received", active "Active",
       inactive "Inactive", converted "Converted",
       received - converted "Not Converted",
       round((converted / received) * 100, 2) "%age Converted"
  from (select area, count(*) received,
                sum(decode(est_sum, 'EC012', 1)) active,
                sum(decode(est_sum, 'EC012', 0, 1)) inactive,
                sum(decode(nis_rad, null, 0, 1)) converted
           from (select case
                           when centre in ('006', '040', '050', '060') then
                            'POST PAID - MAPUTO PROVINCE'
                           when centre not in
                                ('006', '040', '050', '060', '999') then
                            'POST PAID - MAPUTO CITY'
                           else
                            'PREPAID (BOTH CITY AND PROVINCE)'
                         end area, nis_rad, est_sum
                    from int_supply)
          group by area)
 order by 1;
 
 
select 'Prepaid' "Cust. Type", province "Province", area "District",
       count(*) "Count"
  from (select c.boad_designacao province, c.bozd_designacao area, centre,
                client
           from int_supply s, edmcamp.customers_registered_one c
          where nis_rad is not null
            and client = lpad(c.bocl_nocontador, 11, 0)
            and c.rowid in
                (select max(rowid)
                   from edmcamp.customers_registered_one
                  where bocl_nocontador = c.bocl_nocontador))
 group by province, area
union all
select 'Postpaid' "Cust. Type", province "Province", area "District",
       count(*) "Count"
  from (select c.boad_designacao province, c.bozd_designacao area, centre,
                client
           from int_supply s, edmcamp.customers_registered_one c
          where nis_rad is not null
            and s.centre = lpad(c.bocl_contratoagencia, 3, 0)
            and s.client = lpad(c.bocl_contratonumero, 7, 0)
            and c.rowid in
                (select max(rowid)
                   from edmcamp.customers_registered_one
                  where bocl_nocontador = c.bocl_nocontador))
 group by province, area;

select obs_tariff "Galatee Code", obs_desc "Galatee Tariff", desc_tar "CMS Tariff", count(*) "Count" from (
select b.obs_tariff, b.obs_desc, desc_tar
  from int_supply s, edmgalatee.abon a, mtarifas m, int_map_tariffs b
 where nis_rad is not null
   and s.centre = a.centre
   and s.client = a.client
   and s.ordre = a.ordre
   and s.cod_tar = m.cod_tar
   and b.obs_tariff = lpad(a.tarif, 6, 0)) group by obs_tariff, obs_desc, desc_tar order by 1;
   

select s.cod_tar, desc_tar, sum(imp_tot_rec) total,
       sum(decode(est_sum, 'EC012', imp_tot_rec, 0)) active,
       sum(decode(est_sum, 'EC012', 0, imp_tot_rec)) inactive
  from recibos r, sumcon s, mtarifas m
 where r.nis_rad = s.nis_rad
   and s.cod_tar = m.cod_tar
   and imp_tot_rec <> 0
   --and est_sum = 'EC012'
 group by s.cod_tar, desc_tar;

select desc_tar "Tariff", l.obj_text "Activity", count(*) "Count"
  from sumcon a, lang_dict_db l, mtarifas m
 where l.lang_id = 1
   and l.obj_key = 'CNE.' || cod_cnae
   and a.cod_tar = m.cod_tar
   and tip_suministro = 'SU001'
 group by obj_text, desc_tar order by 2;
 
select l.obj_text, count(*)
  from apmedida_ap a, lang_dict_db l
 where l.lang_id = 1
   and l.obj_key = 'T.' || tip_apa
 group by obj_text;
