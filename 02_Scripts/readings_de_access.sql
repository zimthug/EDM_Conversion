declare
  cursor lcur_readings is
    select to_char(fa.mes_ano, 'yyyymmdd') facture, fa.zona, fa.instalacao,
           fa.mes_ano dateevt, fa.leitura, fa.leiturarea,
           fa.potencia_tomada potencia, fa.kwh, fa.kwhrea,
           fa.energia_facturada, fa.energia_facturadarea,
           fa.potencia_facturada, fa.valor_cobrada, fa.iva bill_tax,
           fa.taxaradio radio, fa.taxalixo garbage_charge,
           fa.taxafixa fixed_charge, fa.diferenca energy,
           tr.valor bill_amount, 0 loses, tr.cobranca paid, sp.nis_rad,
           sec_nis, mt.tip_apa,
           nvl(lag(fa.mes_ano, 1)
                over(partition by sp.nis_rad order by sp.nis_rad, fa.mes_ano),
                to_date(29991231, 'yyyymmdd')) dfac_prev, sp.cod_tar,
           sp.tip_cli, cod_cli, sp.cod_mask, sp.cod_unicom,
           to_char(fa.mes_ano, 'yyyymm') periode, gr_concepto, sec_cta,
           sp.f_alta, sp.client, sp.centre, sp.f_alta f_inst, mt.num_apa,
           mt.co_marca, mt.co_modelo, 0 conso, 0 indexevt
      from edmaccess.facturacao fa, edmaccess.transitado tr, int_meter mt,
           int_supply sp
     where fa.instalacao = tr.instalacao
       and fa.zona = tr.zona
       and fa.mes_ano = tr.mes_ano
       and tr.opedescricao = 'Feg'
       and mt.client = sp.client
       and mt.centre = sp.centre
       and tr.zona = mt.centre
       and tr.instalacao = mt.client
       and sp.nis_rad is not null
       and fa.mes_ano > add_months(sysdate, -24)  
       --and fa.zona = 21 and fa.instalacao = 6500     
       /*and exists (select 0
              from recibos
             where nis_rad = sp.nis_rad
               and f_fact = fa.mes_ano)*/
       and not exists
     (select 0 from apmedida_co where nis_rad = sp.nis_rad and fa.mes_ano = f_lect);
  ll_cte       number;
  ll_commit    number;
  ll_loop      number;
  ll_num_rue   number;
  ll_nis_rad   number;
  ls_tip_csmo  varchar2(5);
  ls_tip_lect  varchar2(5);
  gls_usuario  varchar2(15) := 'CONV_EDM';
  gls_programa varchar2(15) := 'CONV_EDM';
begin
  ll_commit  := 0;
  ll_nis_rad := 0;

  for lcur_readings_rec in lcur_readings loop
  
    if ll_nis_rad <> lcur_readings_rec.nis_rad then
      begin
        select c.multiplicador, 5
          into ll_cte, ll_num_rue
          from edmaccess.contador c
         where to_char(c.zona) = lcur_readings_rec.centre
           and to_char(c.no_da_instalacao) = lcur_readings_rec.client;
      exception
        when no_data_found then
          ll_cte     := 1;
          ll_num_rue := 5;
        when too_many_rows then
          ll_cte     := 1;
          ll_num_rue := 5;
      end;
    
      if ll_cte = 0 then
        ll_cte := 1;
      end if;
    
      if ll_num_rue > 8 then
        ll_num_rue := 8;
      end if;
    
    end if;
  
    ls_tip_lect := 'RA005';
  
    /*{%skip}if lcur_readings_rec.point = 1 and
       lcur_readings_rec.tip_apa = 'TA101' then
      ls_tip_csmo := 'CO111';
    elsif lcur_readings_rec.point = 1 and
          lcur_readings_rec.tip_apa <> 'TA101' then
      ls_tip_csmo := 'CO111';
    elsif lcur_readings_rec.point = 2 and
          lcur_readings_rec.tip_apa <> 'TA101' then
      ls_tip_csmo := 'CO331';
    elsif lcur_readings_rec.point = 3 and
          lcur_readings_rec.tip_apa <> 'TA101' then
      ls_tip_csmo := 'CO551';
    end if;*/
  
    ls_tip_csmo := 'CO111';
  
    ll_num_rue := nvl(ll_num_rue, 5);
  
    if ll_nis_rad <> lcur_readings_rec.nis_rad then
    
      if lcur_readings_rec.tip_apa = 'TA165' then
        ll_loop := 3;
      else
        ll_loop := 1;
      end if;
    
      for jk in 1 .. ll_loop loop
        if jk = 1 then
          ls_tip_csmo := 'CO111';
        elsif jk = 2 then
          ls_tip_csmo := 'CO331';
        elsif jk = 3 then
          ls_tip_csmo := 'CO551';
        end if;
      
        begin
        
          insert into apmedida_param
            (usuario, f_actual, programa, num_apa, co_marca, f_val,
             tip_csmo, coef_per, cte_prim, cte_secund, peso_entr, peso_sal,
             num_rue)
          values
            (gls_usuario, trunc(sysdate), gls_programa,
             lcur_readings_rec.num_apa, lcur_readings_rec.co_marca,
             nvl(lcur_readings_rec.f_inst, lcur_readings_rec.f_alta),
             ls_tip_csmo, 0, ll_cte, 1, 0, 0, ll_num_rue);
        exception
          when dup_val_on_index then
            null;
        end;
      
      end loop;
    
    end if;
  
    begin
    
      if lcur_readings_rec.tip_apa = 'TA165' then
        ll_loop := 3;
      else
        ll_loop := 1;
      end if;
    
      for jk in 1 .. ll_loop loop
        if jk = 1 then
          ls_tip_csmo                := 'CO111';
          lcur_readings_rec.conso    := lcur_readings_rec.kwh;
          lcur_readings_rec.indexevt := lcur_readings_rec.leitura;
        elsif jk = 2 then
          ls_tip_csmo                := 'CO331';
          lcur_readings_rec.conso    := lcur_readings_rec.kwhrea;
          lcur_readings_rec.indexevt := lcur_readings_rec.leiturarea;
        elsif jk = 3 then
          ls_tip_csmo                := 'CO551';
          lcur_readings_rec.conso    := lcur_readings_rec.potencia * ll_cte;
          lcur_readings_rec.indexevt := lcur_readings_rec.potencia * ll_cte;
        end if;
      
        insert into apmedida_co
          (usuario, f_actual, programa, nis_rad, num_apa, co_marca,
           tip_csmo, lect, f_lect, csmo, cte, tip_lect, f_fact, dif_lect,
           sec_rec, num_rue, sec_lect, lect_ant, f_trat, co_al, cod_emp,
           time_lect, dec_part)
        values
          (gls_usuario, trunc(sysdate), gls_programa,
           lcur_readings_rec.nis_rad, lcur_readings_rec.num_apa,
           lcur_readings_rec.co_marca, ls_tip_csmo,
           lcur_readings_rec.indexevt, lcur_readings_rec.dateevt,
           lcur_readings_rec.conso, ll_cte, ls_tip_lect,
           lcur_readings_rec.dateevt, lcur_readings_rec.conso / ll_cte, 0, ll_num_rue,
           0, 0, lcur_readings_rec.dateevt, 'AN000', 0, 0, 0);
      
      end loop;
    
      if ll_nis_rad <> lcur_readings_rec.nis_rad then
        ll_commit := ll_commit + 1;
      end if;
    
      if mod(ll_commit, 1000) = 0 then
        commit;
      end if;
    
      ll_nis_rad := lcur_readings_rec.nis_rad;
    
    exception
      when dup_val_on_index then
        null;
      when others then
        dbms_output.put_line(sqlerrm || ':' || lcur_readings_rec.nis_rad);
    end;
  
  end loop;
  commit;
  conversion_pck.p06_readings_cleanup;
end;
