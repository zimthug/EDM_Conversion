declare
  cursor lcur_trans is
    select sp.nis_rad, sp.cod_calle, br.puissanceinstallee, br.pertes,
           '201403250000000' bopt_nopt
      from edmgalatee.brt br, int_supply sp
     where sp.centre = br.centre
       and sp.client = br.ag
       and exists (select *
              from sumcon
             where nis_rad = sp.nis_rad
               and cod_mask = 4096)
       and pertes is not null
       and pertes > 0;
  ll_marca     number;
  ls_co_marca  varchar2(5);
  ls_bopt_nopt varchar2(20) := ' ';
begin
  ll_marca := 1;
  for lcur_trans_rec in lcur_trans loop
  
    ls_co_marca              := 'ZT001';
    ll_marca                 := ll_marca + 1;
    lcur_trans_rec.bopt_nopt := to_char(sysdate, 'yyyymmdd') ||
                                lpad(ll_marca, 6, 0);
  
    update sumcon_rel
       set f_anul = trunc(sysdate)
     where nis_rad = lcur_trans_rec.nis_rad;
  
    begin
      insert into transformadores
        (usuario, f_actual, programa, num_transf, co_marca, pot_nominal,
         tip_la, tip_rel_kv, co_prop_trafo, kvarh, ref_doc_comp, f_vcto_comp,
         cod_calle, num_puerta, duplicador, est_transf, f_camb_est,
         co_ubic_med, porc_perdida, f_val, f_anul, num_grupo, num_subest,
         tip_explot, datos, observacion, tip_tension)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_trans_rec.bopt_nopt,
         ls_co_marca, lcur_trans_rec.puissanceinstallee, 'LA001', 'RT001',
         'PA003', lcur_trans_rec.pertes * 1000, ' ',
         to_date(29991231, 'yyyymmdd'), lcur_trans_rec.cod_calle, 0, '| ',
         'CT001', to_date(19990101, 'yyyymmdd'), 'S', 0,
         to_date(19990101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'), 0, 0,
         'EX001', '/0/0/', 'PT From Galatee for MT customers', 'TT000');
    exception
      when dup_val_on_index then
        null;
    end;
  
    begin
      insert into sumcon_rel
        (usuario, f_actual, programa, nis_rad, sec_apa, num_transf,
         co_marca, porc_uso_compart, f_val, f_anul, porc_perd)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_trans_rec.nis_rad, 1,
         lcur_trans_rec.bopt_nopt, ls_co_marca, 1,
         to_date(19990101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'), 0);
    exception
      when dup_val_on_index then
        null;
    end;
  
  end loop;
end;

/*
select * from sumcon_rel;

select * from transformadores;
*/
