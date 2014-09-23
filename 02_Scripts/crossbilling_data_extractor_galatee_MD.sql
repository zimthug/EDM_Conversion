insert into edm_fact_summary
select centre || client || ordre account_id, nis_rad, centre, client, ordre,
       bill_no, bill_date, periode, energy energy_amt, fixed_charge,
       radio radio_charge, garbage_charge, loses loses_charge,
       /*potencia*/ 0 power_amt, read_type, coeflect usage_constant, curr_active,
       prev_active, active_cons cons_active, active_amt, curr_reactive,
       prev_reactive, reactive_cons cons_reactive, reactive_amt, curr_demand,
       demand_cons cons_demand, demand_amt, trans_load, metering_side,
       bill_amount, bill_tax, tranche_1, tranche_1_csmo, tranche_2,
       tranche_2_csmo, tranche_3, tranche_3_csmo, cod_tar, cod_munic,
       computed_usage, billed_usage, pot
  from (select en.centre, en.client, en.ordre, en.facture bill_no,
                en.dfac bill_date, en.periode, en.totfttc bill_amount,
                en.totftax bill_tax,
                /*nvl(max((select sum(montant)
                                                                                                           from edmgalatee.lclient
                                                                                                          where centre = sp.centre
                                                                                                            and client = sp.client
                                                                                                            and ordre = sp.ordre
                                                                                                            and ndoc = en.facture
                                                                                                            and dc = 'C'
                                                                                                            and coper not in ('078', '080'))), 0) paid,*/
                sum(case
                      when redevance in ('01', '02', '03', '04') then
                       redht
                      else
                       0
                    end) energy,
                sum(case
                      when redevance in ('11', '12', '18', '17') then
                       redht
                      else
                       0
                    end) fixed_charge,
                sum(case
                      when redevance in ('14') then
                       redht
                      else
                       0
                    end) radio,
                sum(case
                      when redevance in ('15') then
                       redht
                      else
                       0
                    end) garbage_charge,
                sum(case
                      when redevance in ('08') then
                       redht
                      else
                       0
                    end) loses,
                sum(case
                      when redevance in ('06', '13') then
                       redht
                      else
                       0
                    end) potencia,
                nvl(max((select nvl(pertes, 0)
                           from edmgalatee.brt
                          where centre = cp.centre
                            and ag = cp.client)), 0) trans_load,
                1 metering_side
                /* Find from EDM*/,
                 /*cp.point, cp.compteur, cp.aindex,
                                cp.nindex, max(cp.conso) conso,*/ cp.coeflect,
                /*max(cp.conso) computed_usage,*/
                 /*max(cp.consofac) billed_usage,*/
                /*decode(cp.tfac, 1, 'ACTUAL', 'ESTIMATE')*/
                'ACTUAL' read_type,
                /* cp.totproht,*/
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 1 then
                       redht
                      else
                       0
                    end) tranche_1,
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 2 then
                       redht
                      else
                       0
                    end) tranche_2,
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 3 then
                       redht
                      else
                       0
                    end) tranche_3,
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 1 then
                       re.quantite
                      else
                       0
                    end) tranche_1_csmo,
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 2 then
                       re.quantite
                      else
                       0
                    end) tranche_2_csmo,
                sum(case
                      when redevance in ('01', '02', '03', '04') and
                           re.tranche = 3 then
                       re.quantite
                      else
                       0
                    end) tranche_3_csmo,
                max((select max(nis_rad)
                       from int_supply
                      where centre = sp.centre
                        and client = sp.client
                        and ordre = sp.ordre)) nis_rad,
                max((select max(ee.cod_tar)
                       from int_supply ef, sumcon ee
                      where centre = sp.centre
                        and client = sp.client
                        and ordre = sp.ordre
                        and ef.nis_rad = ee.nis_rad)) cod_tar,
                max((select max(cod_munic)
                       from int_supply aa, callejero ab
                      where aa.cod_calle = ab.cod_calle
                        and centre = sp.centre
                        and client = sp.client
                        and ordre = sp.ordre)) cod_munic,
                round(ax.puissance, 2) pot, prev_active, curr_active,
                active_cons, active_amt, prev_demand, curr_demand, demand_cons,
                demand_amt, prev_reactive, curr_reactive, reactive_cons,
                reactive_amt, computed_usage, billed_usage
           from edmgalatee.client sp, edmgalatee.centfac en,
                edmgalatee.credfac re,
                (select k.centre, k.client, k.ordre, k.facture,
                         max(decode(k.point, 1, k.aindex, 0)) prev_active,
                         max(decode(k.point, 1, k.nindex, 0)) curr_active,
                         max(decode(k.point, 1, k.consofac, 0)) active_cons,
                         max(decode(k.point, 1, k.totproht, 0)) active_amt,
                         max(decode(k.point, 2, k.aindex, 0)) prev_demand,
                         max(decode(k.point, 2, k.nindex, 0)) curr_demand,
                         max(decode(k.point, 2, k.consofac, 0)) demand_cons,
                         max(decode(k.point, 2, k.totproht, 0)) demand_amt,
                         max(decode(k.point, 3, k.aindex, 0)) prev_reactive,
                         max(decode(k.point, 3, k.nindex, 0)) curr_reactive,
                         max(decode(k.point, 3, k.consofac, 0)) reactive_cons,
                         max(decode(k.point, 3, k.totproht, 0)) reactive_amt,
                         max(decode(k.point, 1, k.conso, 0)) computed_usage,
                         max(decode(k.point, 1, k.consofac, 0)) billed_usage,
                         k.coeflect
                    from edmgalatee.cprofac k
                   where periode = '201312'
                   group by k.centre, k.client, k.ordre, k.facture, k.coeflect) cp,
                edmgalatee.abon ax
          where sp.centre = en.centre
            and sp.centre = re.centre
            and sp.client = en.client
            and sp.client = re.client
            and en.facture = re.facture
            and sp.centre = cp.centre
            and sp.client = cp.client
            and en.facture = cp.facture
            and en.coper = '001'
               --and sp.client = '0600012'
               --and en.facture = '573221'
            --and cp.centre || cp.client || cp.ordre = '002020101301'
            and cp.centre = ax.centre
            and cp.client = ax.client
            and cp.ordre = ax.ordre
            and en.periode = '201312'
            and en.centre /*not*/
                in ('006', '002')
          group by en.centre, en.client, en.ordre, en.facture, en.totfttc,
                   en.totftax, en.dfac, en.periode,
                    /*cp.point, cp.compteur,
                                     cp.aindex, cp.nindex,  cp.conso, consofac,*/
                   cp.coeflect,
                   /* decode(cp.tfac, 1, 'ACTUAL', 'ESTIMATE'), cp.totproht,*/
                   1, round(ax.puissance, 2), prev_active, curr_active,
                active_cons, active_amt, prev_demand, curr_demand, demand_cons,
                demand_amt, prev_reactive, curr_reactive, reactive_cons,
                reactive_amt, computed_usage, billed_usage)
 group by centre || client || ordre, centre, client, ordre, bill_no,
          bill_date, periode, energy, fixed_charge, radio, garbage_charge,
          loses, potencia, read_type, decode(coeflect, 0, 1, coeflect),
          trans_load, metering_side, bill_amount, bill_tax, tranche_1,
          tranche_1_csmo, tranche_2, tranche_2_csmo, tranche_3,
          tranche_3_csmo, nis_rad, cod_tar, cod_munic, /*computed_usage,*/
          /* billed_usage,*/ pot, coeflect, curr_active,
       prev_active, active_cons, active_amt, curr_reactive,
       prev_reactive, reactive_cons, reactive_amt, curr_demand,
       demand_cons, demand_amt, computed_usage, billed_usage;
