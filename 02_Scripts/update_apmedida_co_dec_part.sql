-- select * from apmedida_co where nis_rad = 201268132;

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
