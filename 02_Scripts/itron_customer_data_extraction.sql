select s.nis_rad || '-' || lpad(s.sec_nis, 2, 0) cms_references,
       ap.num_apa meter_no, cj.cod_calle street_code, cj.nom_calle "STREET/BAIRRO", ltrim(f.acc_finca, '|') address
  from sumcon s, fincas f, callejero cj, apmedida_ap ap
 where s.cod_mask = 2048
   and cj.cod_calle = f.cod_calle
   and ap.nis_rad = s.nis_rad
   and est_sum = 'EC012'
   and f.nif = s.nif
   and cj.cod_calle != 100245;
