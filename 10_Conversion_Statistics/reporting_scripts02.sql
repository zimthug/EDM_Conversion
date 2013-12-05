select district, status, converted, total, total - converted difference,
       round((converted / total) * 100, 2) percentage_converted
  from (select c.bodt_designacao district,
                decode(trim(dres), null, 'Active', 'Inactive') status, est_sum,
                sum((select decode(nis_rad, null, 0, 1)
                       from int_supply
                      where conv_id = s.conv_id)) converted, count(*) total
           from edmcamp.customers_registered_one c, int_supply s,
                edmgalatee.abon a
          where c.bocl_contratoagencia = to_number(s.centre)
            and c.bocl_contratonumero = to_number(s.client)
            and a.centre = s.centre
            and a.client = s.client
            and a.ordre = s.ordre
            and c.rowid in (select max(rowid) from edmcamp.customers_registered_one where bocl_contratoagencia = c.bocl_contratoagencia
            and bocl_contratonumero = c.bocl_contratonumero)
          group by c.bodt_designacao,
                   decode(trim(dres), null, 'Active', 'Inactive'), est_sum)
 order by 1, 2;

select tariff_code, tariff_desc, active, inactive, active + inactive total
  from (select su.cod_tar tariff_code, desc_tar tariff_desc,
                sum(decode(est_sum, 'EC012', 1, 0)) active,
                sum(decode(est_sum, 'EC021', 1, 0)) inactive
           from sumcon su, mtarifas mt
          where nis_rad in (select nis_rad from int_supply)
            and mt.cod_tar = su.cod_tar
          group by su.cod_tar, desc_tar)
 order by 1;

select meter_status, prepaid, Single_Usage_Active, Act_reac_demand,
       prepaid + Single_Usage_Active + Act_reac_demand total
  from (select *
           from (select ap.tip_apa, /*la.obj_text meter_type,*/
                         lo.obj_text meter_status, count(*) total
                    from aparatos ap, lang_dict_db la, lang_dict_db lo
                   where 'T.' || ap.tip_apa = la.obj_key
                     and la.lang_id = 1
                     and lo.lang_id = la.lang_id
                     and ap.est_apa = substr(lo.obj_key, 3)
                     and ap.programa = 'CONV_EDM'
                   group by ap.tip_apa, la.obj_text, lo.obj_text) pivot(sum(total) for(tip_apa) in('TA100' as
                                                                                                   Prepaid,
                                                                                                   'TA101' as
                                                                                                    Single_Usage_Active,
                                                                                                   'TA165' as
                                                                                                    Act_reac_demand)));

select s.nis_rad, d.obj_text, m.desc_tar, /*sum(decode(dc, 'C', -montant, montant)) galatee_amount,*/ sum((select imp_tot_rec from recibos
where nis_rad = s.nis_rad)) converted_amount
  from edmgalatee.lclient l, int_supply s, lang_dict_db d, mtarifas m
 where l.centre = s.centre
   and l.client = s.client
   and l.ordre = s.ordre
   and d.lang_id = 1
   and 'E.'||s.est_sum = d.obj_key
   and s.nis_rad is not null
   and s.cod_tar = m.cod_tar
group by s.nis_rad, d.obj_text, desc_tar
