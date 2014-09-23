declare
  cursor ix is 
select 200057421 nis_rad, 230.6 nominal from dual union
select 200055110 nis_rad, 230.4 nominal from dual union
select 200055253 nis_rad, 440 nominal from dual union
select 200055274 nis_rad, 136.8 nominal from dual union
select 200055276 nis_rad, 136.8 nominal from dual union
select 200057477 nis_rad, 82.8 nominal from dual union
select 200055104 nis_rad, 82.8 nominal from dual union
select 200057361 nis_rad, 432 nominal from dual union
select 200052713 nis_rad, 230.4 nominal from dual union
select 200057214 nis_rad, 236 nominal from dual union
select 200052969 nis_rad, 765 nominal from dual union
select 200053031 nis_rad, 275.4 nominal from dual union
select 200055236 nis_rad, 1080 nominal from dual union
select 200052851 nis_rad, 396 nominal from dual union
select 200053327 nis_rad, 396 nominal from dual union
select 200054469 nis_rad, 393 nominal from dual union
select 200054433 nis_rad, 82.8 nominal from dual union
select 200055386 nis_rad, 295 nominal from dual union
select 200056440 nis_rad, 136.8 nominal from dual union
select 200056498 nis_rad, 396 nominal from dual union
select 200055037 nis_rad, 396 nominal from dual union
select 200054941 nis_rad, 561.6 nominal from dual union
select 200054958 nis_rad, 561.6 nominal from dual union
select 200054966 nis_rad, 160 nominal from dual union
select 200056273 nis_rad, 396 nominal from dual union
select 200056479 nis_rad, 39.6 nominal from dual union
select 200056297 nis_rad, 136.6 nominal from dual union
select 200056324 nis_rad, 396 nominal from dual union
select 200056326 nis_rad, 325 nominal from dual union
select 200054907 nis_rad, 215 nominal from dual union
select 200055002 nis_rad, 175 nominal from dual union
select 200055029 nis_rad, 383 nominal from dual union
select 200055031 nis_rad, 286 nominal from dual union
select 200055033 nis_rad, 215 nominal from dual union
select 200055035 nis_rad, 792 nominal from dual union
select 200056482 nis_rad, 175 nominal from dual union
select 200056507 nis_rad, 396 nominal from dual union
select 200056509 nis_rad, 230.4 nominal from dual union
select 200056511 nis_rad, 275 nominal from dual union
select 200056354 nis_rad, 236.5 nominal from dual union
select 200056398 nis_rad, 393 nominal from dual union
select 200056410 nis_rad, 393 nominal from dual union
select 200054638 nis_rad, 275 nominal from dual union
select 200054659 nis_rad, 215 nominal from dual union
select 200057024 nis_rad, 275 nominal from dual union
select 200057030 nis_rad, 236 nominal from dual union
select 200057117 nis_rad, 285 nominal from dual union
select 200057118 nis_rad, 286 nominal from dual union
select 200057119 nis_rad, 286 nominal from dual union
select 200057899 nis_rad, 295 nominal from dual union
select 200053832 nis_rad, 298 nominal from dual union
select 200057268 nis_rad, 82.8 nominal from dual union
select 200057331 nis_rad, 82.8 nominal from dual union
select 200057456 nis_rad, 261 nominal from dual union
select 200055214 nis_rad, 396 nominal from dual union
select 200057457 nis_rad, 82.8 nominal from dual union
select 200057301 nis_rad, 82.8 nominal from dual union
select 200052983 nis_rad, 396 nominal from dual union
select 200052806 nis_rad, 209 nominal from dual union
select 200053015 nis_rad, 230.4 nominal from dual union
select 200053489 nis_rad, 396 nominal from dual union
select 200054450 nis_rad, 561.6 nominal from dual union
select 200053311 nis_rad, 792 nominal from dual union
select 200053235 nis_rad, 230.4 nominal from dual union
select 200053541 nis_rad, 82.8 nominal from dual union
select 200054527 nis_rad, 136.8 nominal from dual union
select 200054593 nis_rad, 236.8 nominal from dual union
select 200053545 nis_rad, 186 nominal from dual union
select 200053565 nis_rad, 136.8 nominal from dual union
select 200054431 nis_rad, 396 nominal from dual union
select 200056628 nis_rad, 230.4 nominal from dual union
select 200056471 nis_rad, 230.4 nominal from dual union
select 200056499 nis_rad, 561.6 nominal from dual union
select 200054942 nis_rad, 396 nominal from dual union
select 200054959 nis_rad, 173 nominal from dual union
select 200056298 nis_rad, 175 nominal from dual union
select 200056300 nis_rad, 792 nominal from dual union
select 200056321 nis_rad, 396 nominal from dual union
select 200056325 nis_rad, 230.4 nominal from dual union
select 200054630 nis_rad, 150 nominal from dual union
select 200055003 nis_rad, 230.4 nominal from dual union
select 200055030 nis_rad, 393 nominal from dual union
select 200055034 nis_rad, 75 nominal from dual union
select 200056483 nis_rad, 396 nominal from dual union
select 200056506 nis_rad, 215 nominal from dual union
select 200056508 nis_rad, 175 nominal from dual union
select 200056513 nis_rad, 275 nominal from dual union
select 200056355 nis_rad, 275 nominal from dual union
select 200056358 nis_rad, 393 nominal from dual union
select 200056366 nis_rad, 393 nominal from dual union
select 200056399 nis_rad, 393 nominal from dual union
select 200055124 nis_rad, 286 nominal from dual union
select 200057900 nis_rad, 215 nominal from dual union
select 200057901 nis_rad, 275 nominal from dual union
select 200057902 nis_rad, 275 nominal from dual union
select 200057903 nis_rad, 275 nominal from dual union
select 200057904 nis_rad, 275 nominal from dual union
select 200057905 nis_rad, 275 nominal from dual union
select 200055368 nis_rad, 275 nominal from dual union
select 200055442 nis_rad, 296 nominal from dual union
select 200053688 nis_rad, 215 nominal from dual ;
  ll_trans number := 0;
  ll_pot_nominal number := 0;
begin
  for x in ix loop
  
    ll_trans := ll_trans + 1;
    
    select pot into ll_pot_nominal from sumcon where nis_rad = x.nis_rad;
    
    x.nominal := x.nominal * 1000;
  
    insert into transformadores
      (usuario, f_actual, programa, num_transf, co_marca, pot_nominal,
       tip_la, tip_rel_kv, co_prop_trafo, kvarh, ref_doc_comp, f_vcto_comp,
       cod_calle, num_puerta, duplicador, est_transf, f_camb_est,
       co_ubic_med, porc_perdida, f_val, f_anul, num_grupo, num_subest,
       tip_explot, datos, observacion, tip_tension)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM',
       'XX-TX-' || lpad(ll_trans, 3, 0), 'ZT001', ll_pot_nominal, 'LA001',
       'RT001', 'PA003', x.nominal, ' ', to_date(29991231, 'yyyymmdd'), 0,
       9999, '| ', 'CT001', to_date(29991231, 'yyyymmdd'), 'S', 0,
       to_date(20010101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'), 0, 0,
       'EX001', ' ', ' ', 'TT001');
  
    insert into sumcon_rel
      (usuario, f_actual, programa, nis_rad, sec_apa, num_transf, co_marca,
       porc_uso_compart, f_val, f_anul, porc_perd)
    values
      ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.nis_rad, 1,
       'XX-TX-' || lpad(ll_trans, 3, 0), 'ZT001', 1,
       to_date(20010101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'), 0);
       
  end loop;
end;




/*

select t.* from sumcon_rel a, transformadores t 
where nis_rad = 200057421
and a.num_transf = t.num_transf

*/
