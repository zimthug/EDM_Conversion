declare
  cursor ix is
    select sp.nis_rad, sp.sec_nis, ca.centre, ca.ag, ca.compteur,
           coefcomptage, ca.point,
           decode(point, 1, 'CO111', 2, 'CO551', 3, 'CO331') tip_csmo
      from edmgalatee.canalisation ca, int_supply sp
     where coefcomptage > 0
       and ca.centre = sp.centre
       and ca.ag = sp.client
       and sp.nis_rad is not null;
begin
  for x in ix loop
    update apmedida_param
       set num_rue = num_rue + (x.coefcomptage * .1)
     where (num_apa, co_marca) in
           (select num_apa, co_marca
              from apmedida_co
             where nis_rad = x.nis_rad)
       and tip_csmo = x.tip_csmo;
  end loop;
end;
/

begin
  for x in (select aa.nis_rad, ap.tip_csmo, ap.num_apa, ap.co_marca,
                   ap.num_rue, (ap.num_rue - round(num_rue)) * 10 dec_part
              from apmedida_param ap, apmedida_ap aa
             where ap.num_rue <> round(ap.num_rue)
               and ap.num_apa = aa.num_apa
               and ap.co_marca = aa.co_marca) loop
               
    update apmedida_co
       set dec_part = x.dec_part
     where nis_rad = x.nis_rad
       and tip_csmo = x.tip_csmo
       and num_apa = x.num_apa
       and co_marca = x.co_marca;
  
  end loop;
end;
/


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