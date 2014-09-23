declare
  ll_commit number := 0;
begin
  for lcur_main_rec in (select nis_rad
                          from int_supply sp
                         where system_id = '01'
                           and not exists (select 0
                                  from ciclo6_galatee_bill_extraction
                                 where nis_rad = sp.nis_rad)
                           and nis_rad is not null
                              --and est_sum = 'EC012'
                           and exists (select 0
                                  from edmgalatee.centfac
                                 where centre = sp.centre
                                   and client = sp.client
                                   and ordre = sp.ordre)) loop
    insert into ciclo6_galatee_bill_extract2
      select en.facture, en.dfac,
             nvl(lag(dfac, 1)
                  over(partition by sp.nis_rad order by sp.nis_rad, dfac),
                  to_date(29991231, 'yyyymmdd')) dfac_prev, sp.nis_rad,
             sp.sec_nis, sp.cod_tar, sp.cod_unicom as cod_unicom,
             en.totfttc bill_amount, en.totftax bill_tax, gr_concepto,
             cod_mask, tip_cli, sec_cta, cod_cli,
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
                 end) potencia, en.periode, sp.f_alta
        from int_supply sp, edmgalatee.centfac en, edmgalatee.credfac re
       where sp.centre = en.centre
         and sp.centre = re.centre
         and sp.client = en.client
         and sp.client = re.client
         and en.facture = re.facture
         and sp.nis_rad is not null
         and en.coper = '001'
         and dfac is not null
            /*and not exists
            (select 0 from recibos where nis_rad = sp.nis_rad)*/
            --and (sp.nis_rad = pll_nis_rad or 0 = pll_nis_rad)
            --and sp.client = '0200029'
         and sp.nis_rad = lcur_main_rec.nis_rad
       group by en.facture, sp.nis_rad, sp.sec_nis, sp.cod_tar,
                sp.cod_unicom, cod_mask, en.totfttc, en.totftax, en.dfac,
                gr_concepto, sec_cta, tip_cli, cod_cli, en.periode,
                sp.f_alta
       order by nis_rad, dfac;
  
    ll_commit := ll_commit + 1;
    if mod(ll_commit, 100) = 0 then
      commit;
    end if;
  
  end loop;
  commit;
end;
