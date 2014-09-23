insert into apa_uso
  select distinct 'CONV_EDM' usuario, trunc(sysdate) f_actual,
                  'CONV_EDM' programa, 'US001' tip_uso, tip_apa, co_marca,
                  co_modelo
    from aparatos
   where (tip_apa, co_marca, co_modelo) in
         (select tip_apa, co_marca, co_modelo
            from aparatos
          minus
          select tip_apa, co_marca, co_modelo
            from apa_uso);

commit;
