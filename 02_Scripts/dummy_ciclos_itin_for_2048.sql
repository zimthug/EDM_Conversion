/*insert into ciclos_ruta
select r.usuario, trunc(sysdate) f_actual, r.programa, r.cod_unicom, r.ruta, ciclo, anyo,
       est_ci_ruta, nl_aus, nl_an, nl_ok, nl_gen, f_iteor, f_fteor, f_ireal,
       f_freal, ind_lect_real, t_generado, t_restante, nl_estim, nl_norealiz,
       na_gen, na_ok, na_aus, na_an, na_no_realiz, na_estim, nc_gen, nc_ok,
       nc_aus, nc_an, nc_no_realiz, nc_estim
  from rutas r, ciclos_ruta c
 where cod_mask = 2048
   and r.cod_unicom = c.cod_unicom
   and c.ruta = 10
   and ciclo in (3, 6, 9, 12);*/

insert into ciclos_itin
select m.usuario, trunc(sysdate) f_actual, m.programa, m.cod_unicom, m.ruta, m.num_itin, ciclo,
       est_itin, nl_aus, nl_an, nl_ok, nl_gen, f_lteor, f_gen, f_recep,
       f_lreal, f_trat, f_fact, cod_lector, accion, num_tpl, nl_estim,
       nl_norealiz, f_estim, ind_trat, read_time, na_gen, na_ok, na_aus,
       na_an, na_no_realiz, na_estim, nc_gen, nc_ok, nc_aus, nc_an,
       nc_no_realiz, nc_estim
  from mitin m, ciclos_itin c
 where m.ruta = 20
   and m.cod_unicom = c.cod_unicom
   and c.num_itin =
       (select min(num_itin) from mitin where cod_unicom = c.cod_unicom)
   and ciclo in (3, 6, 9, 12)
