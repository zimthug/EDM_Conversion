declare
  cursor lcur_duplicate is
    select m.*, s.est_sum, m.rowid
      from int_meter m, int_supply s
     where (m.num_apa, m.co_marca) in
           (select num_apa, co_marca
              from int_meter ab, int_supply ac
             where ab.centre = ac.centre
               and ab.client = ac.client
               --and ab.ordre = ac.ordre
               and ac.nis_rad is not null
             group by num_apa, co_marca
            having count(*) > 1)
       and m.centre = s.centre
       and m.client = s.client
       --and m.ordre = s.ordre
     order by m.num_apa, m.co_marca, est_sum;
  ll_same         number := 0;
  lb_loop         boolean := true;
  ls_num_apa      varchar2(20) := ' ';
  ls_co_marca     varchar2(10) := ' ';
  ls_co_marca_dup varchar2(10) := ' ';
begin
  --while lb_loop loop
    lb_loop := false;
    for lcur_duplicate_rec in lcur_duplicate loop
      lb_loop := true;
    
      if ls_num_apa = lcur_duplicate_rec.num_apa and
         ls_co_marca = lcur_duplicate_rec.co_marca then
      
        ll_same := ll_same + 1;
      
        select cod
          into ls_co_marca_dup
          from (select cod, rownum re
                   from (select cod
                            from codigos
                           where cod like 'MC___'
                             and cod_mask >= 1024
                             and cod_mask != 2048
                           order by 1))
         where re = ll_same;
      
        update int_meter
           set co_marca = ls_co_marca_dup
         where rowid = lcur_duplicate_rec.rowid;
      
      else
        ll_same := 0;
      end if;
    
      ls_num_apa  := lcur_duplicate_rec.num_apa;
      ls_co_marca := lcur_duplicate_rec.co_marca;
    
    end loop;
  --end loop;
end;
