declare
  cursor ix is
    select *
      from recibos r
     where imp_cta <> 0
       and exists
     (select 0
              from imp_concepto
             where nis_rad = r.nis_rad
               and sec_nis = r.sec_nis
               and sec_rec = r.sec_rec
               and f_fact = r.f_fact having sum(imp_cta_cto) = 0);
       --and nis_rad = 200055491;

  cursor lc(pnis_rad in number,
            psec_nis in number,
            psec_rec in number,
            pf_fact  in date) is
    select e.*, rowid
      from imp_concepto e
     where nis_rad = pnis_rad
       and sec_nis = psec_nis
       and sec_rec = psec_rec
       and f_fact = pf_fact
     order by sec_concepto;
  ll_left    number := 0;
  ll_paid    number := 0;
  ll_imp_cta number := 0;
begin
  for x in ix loop
    if x.est_act = 'ER310' then
      update imp_concepto
         set imp_cta_cto = imp_concepto
       where nis_rad = x.nis_rad
         and sec_nis = x.sec_nis
         and sec_rec = x.sec_rec
         and f_fact = x.f_fact;
    else
      ll_left := x.imp_cta;
      for lx in lc(x.nis_rad, x.sec_nis, x.sec_rec, x.f_fact) loop
       
       if ll_left > lx.imp_concepto then
         ll_imp_cta := lx.imp_concepto;
       elsif ll_left <= 0 then
         ll_imp_cta := 0;
       else
         ll_imp_cta := ll_left;
       end if;
       
       ll_left := ll_left - lx.imp_concepto;
             
        update imp_concepto
           set imp_cta_cto = ll_imp_cta
         where rowid = lx.rowid;
      end loop;
    end if;
  end loop;
end;

--  select * from imp_concepto where nis_rad = 200055491 and f_fact = to_date('20140712', 'yyyymmdd') order by f_fact desc, sec_concepto


insert into pagos_concepto
select p.usuario, p.f_actual, p.programa, p.sec_rec, p.nis_rad, p.sec_nis,
       p.f_fact, sec_pago, co_concepto, sec_concepto, csmo_fact,
       imp_cta_cto imp_total, 0 imp_base_iva, imp_iva, 2 ind_anulado
  from pagos p, imp_concepto i
 where i.nis_rad = p.nis_rad
   and i.sec_nis = p.sec_nis
   and i.sec_rec = p.sec_rec
   and i.f_fact = p.f_fact
   and i.imp_cta_cto <> 0
   /*and i.nis_rad = 200053224
   and i.f_fact = to_date('20140731', 'yyyymmdd')*/
   and not exists (select 0
          from pagos_concepto
         where nis_rad = i.nis_rad
           and sec_nis = i.sec_nis
           and sec_rec = i.sec_rec
           and f_fact = i.f_fact
           and co_concepto = i.co_concepto) and sec_pago = 1;

begin
  for x in (select i.*
              from pagos p, imp_concepto i
             where i.nis_rad = p.nis_rad
               and i.sec_nis = p.sec_nis
               and i.sec_rec = p.sec_rec
               and i.f_fact = p.f_fact
               and i.imp_cta_cto <> 0
               and not exists (select 0
                      from pagos_concepto
                     where nis_rad = i.nis_rad
                       and sec_nis = i.sec_nis
                       and sec_rec = i.sec_rec
                       and f_fact = i.f_fact
                       and co_concepto = i.co_concepto)
               --and i.nis_rad = 200055491
               and exists (select 0
                      from pagos_concepto
                     where nis_rad = i.nis_rad
                       and sec_nis = i.sec_nis
                       and sec_rec = i.sec_rec
                       and f_fact = i.f_fact
                       and programa = 'CONV_EDM')) loop
    delete pagos_concepto
     where nis_rad = x.nis_rad
       and sec_nis = x.sec_nis
       and sec_rec = x.sec_rec
       and f_fact = x.f_fact
       and programa = 'CONV_EDM';
  end loop;
end;

