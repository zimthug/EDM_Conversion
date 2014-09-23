declare
  cursor lcur_trans is
    select *
      from (select sp.nis_rad, system_id, ca.bopt_nopt,
                    trim(ca.bopt_designacao) bopt_designacao, cod_calle
               from int_supply sp, edmcamp.cadastramento_new ca
              where sp.client = ca.bocl_contratonumero
                and sp.nis_rad is not null
                and ca.bopt_nopt != '#NAME?'
                and trim(bopt_designacao) is not null
             union all
             select sp.nis_rad, system_id, ca.bopt_nopt,
                    trim(ca.bopt_designacao) bopt_designacao, cod_calle
               from int_supply sp, edmcamp.cadastramento_new ca
              where sp.client = lpad(ca.bocl_nocontador, 11, 0)
                and sp.nis_rad is not null
                and ca.bopt_nopt != '#NAME?'
                and trim(bopt_designacao) is not null)
     order by bopt_nopt, bopt_designacao;
  ll_marca           number;
  ls_co_marca        varchar2(5);
  ls_bopt_nopt       varchar2(20) := ' ';
  ls_bopt_designacao varchar2(80) := ' ';
begin
  for lcur_trans_rec in lcur_trans loop
    if ls_bopt_nopt != lcur_trans_rec.bopt_nopt or
       ls_bopt_designacao != lcur_trans_rec.bopt_designacao then
    
      select count(*)
        into ll_marca
        from transformadores
       where num_transf = lcur_trans_rec.bopt_nopt;
    
      if ll_marca = 1 then
        ls_co_marca := 'ZT001';
      elsif ll_marca = 2 then
        ls_co_marca := 'ZT002';
      else
        ls_co_marca := 'ZT009';
      end if;
    
      begin
        insert into transformadores
          (usuario, f_actual, programa, num_transf, co_marca, pot_nominal,
           tip_la, tip_rel_kv, co_prop_trafo, kvarh, ref_doc_comp,
           f_vcto_comp, cod_calle, num_puerta, duplicador, est_transf,
           f_camb_est, co_ubic_med, porc_perdida, f_val, f_anul, num_grupo,
           num_subest, tip_explot, datos, observacion, tip_tension)
        values
          ('CONV_EDM', trunc(sysdate), 'CONV_EDM', lcur_trans_rec.bopt_nopt,
           ls_co_marca, 1, 'LA001', 'RT001', 'PA003', 1100, ' ',
           to_date(29991231, 'yyyymmdd'), lcur_trans_rec.cod_calle, 0, '| ',
           'CT001', to_date(19990101, 'yyyymmdd'), 'P', 0,
           to_date(19990101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'), 0,
           0, 'EX001', '/0/0/',
           substr(lcur_trans_rec.bopt_designacao, 1, 50), 'TT000');
      exception
        when dup_val_on_index then
          null;
      end;
    end if;
  
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
  
    ls_bopt_nopt       := lcur_trans_rec.bopt_nopt;
    ls_bopt_designacao := lcur_trans_rec.bopt_designacao;
  end loop;
end;


/*
select * from sumcon_rel;

select * from transformadores;
*/
