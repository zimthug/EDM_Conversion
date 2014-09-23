/*begin
  for x in (select hf.rowid, hf.pot_fact, co.csmo
              from hfacturacion hf, apmedida_co co
             where hf.nis_rad = co.nis_rad
               and hf.sec_rec = co.sec_rec
               and hf.sec_nis = 1
               and hf.f_fact = co.f_fact
               and co.tip_csmo = 'CO551') loop
  
    update hfacturacion set pot_fact = x.csmo  where rowid = x.rowid;
  
  end loop;
  commit;
end;*/

begin
  for x in (select hf.rowid, hf.pot_fact, co.csmo, co.nis_rad, ap.num_rue,
                   (co.csmo /
                    power(10, (ap.num_rue - trunc(ap.num_rue)) * 10)) * 10000 new_csmo
              from hfacturacion hf, apmedida_co co, apmedida_param ap
             where hf.nis_rad = co.nis_rad
               and hf.sec_rec = co.sec_rec
               and hf.sec_nis = 1
               and hf.f_fact = co.f_fact
               and co.tip_csmo = 'CO551'
               and co.num_apa = ap.num_apa
               and co.tip_csmo = ap.tip_csmo
               and co.co_marca = ap.co_marca) loop
  
    update hfacturacion set pot_fact = x.new_csmo where rowid = x.rowid;
  
  end loop;
  commit;
end;
/


---UPDATE CSMO_FACT for HFACTURACION
begin
  for x in (select hf.nis_rad, hf.sec_nis, hf.sec_rec, hf.f_fact,
                   hf.csmo_fact, co.csmo, hf.rowid
              from hfacturacion hf, apmedida_co co
             where (hf.nis_rad, hf.sec_nis, hf.sec_rec, hf.f_fact) in
                   (select nis_rad, sec_nis, sec_rec, f_fact
                      from recibos
                     where ind_conversion = 1
                       and tip_rec = 'TR110')
               and hf.nis_rad = co.nis_rad
                  --and hf.sec_nis = co.sec_nis
               and hf.sec_rec = co.sec_rec
               and hf.f_fact = co.f_fact
               and co.tip_csmo = 'CO111'
               and co.csmo > 0) loop
  
    update hfacturacion set csmo_fact = x.csmo where rowid = x.rowid;
  
  end loop;
end;
/
