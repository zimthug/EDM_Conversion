create table edm_fact_summary as
select centre || client || ordre account_id, bill_no, bill_date, periode,
       energy energy_amt, fixed_charge, radio radio_charge, garbage_charge,
       loses loses_charge, potencia power_amt, read_type,
       coeflect usage_constant, sum(decode(point, 1, nindex, 0)) curr_active,
       sum(decode(point, 1, aindex, 0)) prev_active,
       sum(decode(point, 1, conso, 0)) cons_active,
       sum(decode(point, 1, totproht, 0)) active_amt,
       sum(decode(point, 3, nindex, 0)) curr_reactive,
       sum(decode(point, 3, aindex, 0)) prev_reactive,
       sum(decode(point, 3, conso, 0)) cons_reactive,
       sum(decode(point, 3, totproht, 0)) reactive_amt,
       sum(decode(point, 2, nindex, 0)) curr_demand,
       sum(decode(point, 2, conso, 0)) cons_demand,
       sum(decode(point, 2, totproht, 0)) demand_amt, trans_load,
       metering_side, bill_amount, bill_tax
  from (select en.centre, en.client, en.ordre, en.facture bill_no,
                en.dfac bill_date, en.periode, en.totfttc bill_amount,
                en.totftax bill_tax,
                nvl(max((select sum(montant)
                           from edmgalatee.lclient
                          where centre = sp.centre
                            and client = sp.client
                            and ordre = sp.ordre
                            and ndoc = en.facture
                            and dc = 'C'
                            and coper not in ('078', '080'))), 0) paid,
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
                sum(case
                      when redevance in ('08') then
                       0 /*redht  Find out from the Galatee team which one is the correct item*/
                      else
                       0
                    end) trans_load, 1 metering_side /* Find from EDM*/,
                cp.point, cp.compteur, cp.aindex, cp.nindex, cp.conso,
                cp.coeflect,
                decode(cp.tfac, 1, 'ACTUAL', 'ESTIMATE') read_type,
                cp.totproht
           from edmgalatee.client sp, edmgalatee.centfac en,
                edmgalatee.credfac re, (select * from edmgalatee.cprofac) cp
          where sp.centre = en.centre
            and sp.centre = re.centre
            and sp.client = en.client
            and sp.client = re.client
            and en.facture = re.facture
            and sp.centre = cp.centre
            and sp.centre = cp.centre
            and sp.client = cp.client
            and en.facture = cp.facture
            and en.coper = '001'
            and sp.client = '0600012'
            and en.facture = '573221'
            and en.periode = '201312'
           -- and en.centre in ('010', '002')
          group by en.centre, en.client, en.ordre, en.facture, en.totfttc,
                   en.totftax, en.dfac, en.periode, cp.point, cp.compteur,
                   cp.aindex, cp.nindex, cp.conso, cp.coeflect,
                   decode(cp.tfac, 1, 'ACTUAL', 'ESTIMATE'), cp.totproht, 1)
 group by centre || client || ordre, bill_no, bill_date, periode, energy,
          fixed_charge, radio, garbage_charge, loses, potencia, read_type,
          coeflect, trans_load, metering_side, bill_amount, bill_tax;
