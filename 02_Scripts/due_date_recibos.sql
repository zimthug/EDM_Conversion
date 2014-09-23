update recibos
   set f_vcto_fac = to_date(20140825, 'yyyymmdd')
 where to_char(f_fact, 'yyyymm') = '201407'
   and ind_conversion = 1;

commit;
