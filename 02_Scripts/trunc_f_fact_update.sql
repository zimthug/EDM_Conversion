declare
  cursor ix is
    select *
      from recibos
     where trunc(f_fact) != f_fact
       and ind_conversion = 1;
  ll number;
  ll_sec_rec number;
begin
  for x in ix loop
    select count(*)
      into ll
      from recibos
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and f_fact = trunc(x.f_fact);
  
    if ll > 0 then
      ll_sec_rec := x.sec_rec + ll;
      dbms_output.put_line(x.nis_rad||'::'||x.f_fact);
    else
      ll_sec_rec := x.sec_rec;
    end if;
  
    update recibos
       set f_fact = trunc(x.f_fact), sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
    update est_rec
       set f_fact = trunc(x.f_fact), f_inc_est = trunc(x.f_fact),
           sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
    update hfacturacion
       set f_fact = trunc(x.f_fact), f_lect = trunc(x.f_fact),
           sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
    update imp_concepto i
       set f_fact = trunc(x.f_fact), sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
    update sie_asientos_det
       set f_fact = trunc(f_fact), sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
    update apmedida_co
       set f_fact = trunc(f_fact), f_lect = trunc(f_lect),
           f_trat = trunc(f_trat), sec_rec = ll_sec_rec
     where nis_rad = x.nis_rad
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact;
  
  end loop;
  --commit
end;

-- select * from recibos where nis_rad = 200044996;

-- select * from imp_concepto where nis_rad = 200044996

-- select * from est_rec where nis_rad = 200044996

-- select * from hfacturacion where nis_rad = 200044996
