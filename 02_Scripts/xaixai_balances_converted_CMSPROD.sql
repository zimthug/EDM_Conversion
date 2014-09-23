select *
  from (select xa.*, re.nis_rad, re.sec_nis, re.imp_tot_rec, re.f_fact,
                (select desc_tar from mtarifas where cod_tar = su.cod_tar) tariff,
                (select nom_unicom
                    from unicom
                   where cod_unicom = su.cod_unicom) agencia
           from open_u.xaixai_balances@cmspre xa, recibos re, account_assoc aa,
                rel_nis_rutafol rl, sumcon su
          where xa.zona != 100
            and lpad(xa.zona, 2, 0) || '-' || xa.instalacao = rl.folio
            and rl.nis_rad = aa.nis_rad
            and re.nis_rad = aa.nis_rad_sub
            and re.imp_tot_rec = xa.valor
            and re.nis_rad = su.nis_rad
            and codoperacao not in (778)
            and (re.f_fact = datavalor or re.f_fact = mes_ano)
         union
         select xa.*, ca.nis_rad, ca.sec_nis, ca.imp_cargo, ca.f_prod_inic,
                (select desc_tar from mtarifas where cod_tar = su.cod_tar) tariff,
                (select nom_unicom
                    from unicom
                   where cod_unicom = su.cod_unicom) agencia
           from open_u.xaixai_balances@cmspre xa, cargvar ca, account_assoc aa,
                rel_nis_rutafol rl, sumcon su
          where xa.zona != 100
            and lpad(xa.zona, 2, 0) || '-' || xa.instalacao = rl.folio
            and rl.nis_rad = aa.nis_rad
            and ca.nis_rad = aa.nis_rad_sub
            and ca.imp_cargo = xa.valor
            and ca.nis_rad = su.nis_rad
            and codoperacao in (778)
            and (ca.f_prod_inic = datavalor or ca.f_prod_inic = mes_ano)) --where nis_rad = 200052661
