insert into apmedida_param
  select 'CONV_EDM' usuario, trunc(sysdate) f_actual, 'CONV_EDM' programa,
         num_apa, co_marca, f_inst f_val, tip_csmo, 0 coef_per, 1 cte_prim,
         1 cte_secund, 0 peso_entr, 0 peso_sal,
         nvl((select max(num_rue)
                from apmedida_co
               where nis_rad = co.nis_rad
                 and num_apa = co.num_apa
                 and co_marca = co.co_marca),
              5) num_rue
    from apmedida_ap co, csmo_apa ap
   where not exists (select 0
            from apmedida_param
           where num_apa = co.num_apa
             and co_marca = co.co_marca)
     and co.tip_apa = ap.tip_apa;

commit;
