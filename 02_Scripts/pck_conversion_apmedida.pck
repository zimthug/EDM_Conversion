create or replace package pck_conversion_apmedida is
  procedure cp2_int_meter_galatee;

  procedure cp3_apmedida_co;
end pck_conversion_apmedida;
/
create or replace package body pck_conversion_apmedida is
  gls_usuario    varchar2(15) := conversion_pck.gls_usuario;
  gls_programa   varchar2(15) := conversion_pck.gls_programa;
  glf_fechanulla date := to_date(29991231, 'YYYYMMDD');

  /**
  *
  */
  procedure load_galatee_readings_table is
  begin
    insert into galatee_readings
      select cp.centre, cp.client, cp.ordre, sp.nis_rad, sp.sec_nis,
             sp.cod_unicom_serv, sp.cod_cli, sp.nif, cp.point, cp.compteur,
             case
               when substr(trim(cp.compteur), 1, 1) in ('R', 'D') then
                'A' || substr(trim(cp.compteur), 2)
               else
                trim(cp.compteur)
             end num_apa, re.f_fact, nindex lect, tfac, cp.coeflect,
             decode(ca.compteur, null, 'OLD', 'CURR') num_apa_curr,
             ca.cadcompt, facture, cp.conso csmo,
             decode(cp.point, 2, nindex, cp.nindex - cp.aindex) dif_lect
        from edmgalatee.cprofac cp, recibos re, int_supply sp,
             edmgalatee.canalisation ca
       where cp.centre = sp.centre
         and cp.client = sp.client
         and cp.ordre = sp.ordre
         and sp.nis_rad = re.nis_rad
         and re.num_fact = cp.facture
         and cp.centre = ca.centre(+)
         and cp.client = ca.ag(+)
         and cp.compteur = ca.compteur(+)
         and re.tip_rec = 'TR110'
         and cp.topannul is null
         and tfac = 1
         and dev = (select max(dev)
                      from edmgalatee.cprofac
                     where centre = cp.centre
                       and client = cp.client
                       and ordre = cp.ordre
                       and facture = cp.facture);
  end load_galatee_readings_table;

  procedure cp2_int_meter_galatee is
    cursor lcur_int_meter is
      select *
        from galatee_readings g
       where f_fact = (select min(f_fact)
                         from galatee_readings
                        where nis_rad = g.nis_rad
                          and num_apa = g.num_apa)
         and point = (select max(point)
                        from galatee_readings
                       where nis_rad = g.nis_rad
                         and num_apa = g.num_apa)
         and not exists (select 0
                from int_meter
               where num_apa = g.num_apa
                 and nis_rad = g.nis_rad)
       order by nis_rad, num_apa;
    lf_lvto     date;
    ll_same     number;
    ll_conv_id  number;
    ls_tip_apa  varchar2(5);
    ls_num_apa  varchar2(20) := ' ';
    ls_co_marca varchar2(10) := ' ';
  begin
  
    select nvl(max(conv_id), 100000) into ll_conv_id from int_meter;
  
    for lcur_int_meter_rec in lcur_int_meter loop
    
      ll_conv_id := ll_conv_id + 1;
    
      ls_num_apa := lcur_int_meter_rec.num_apa;
    
      if lcur_int_meter_rec.point = 3 then
        ls_tip_apa := 'TA165';
      else
        ls_tip_apa := 'TA101';
      end if;
    
      if lcur_int_meter_rec.num_apa_curr = 'CURR' then
        lf_lvto := glf_fechanulla;
      else
        select max(f_fact)
          into lf_lvto
          from galatee_readings
         where nis_rad = lcur_int_meter_rec.nis_rad
           and num_apa = lcur_int_meter_rec.num_apa;
      end if;
    
      insert into int_meter
        (conv_id, system_id, centre, client, ordre, compteur,
         no_do_contador, num_apa, nis_rad, co_marca, co_modelo, tip_apa,
         est_apa, co_prop_apa, f_inst, cte_apa, f_fabric, sec_pm, sec_apa,
         f_lvto
         /*, camp_num_apa, camp_date, camp_co_marca, ind_converted*/)
      values
        (ll_conv_id, '01', lcur_int_meter_rec.centre,
         lcur_int_meter_rec.client, lcur_int_meter_rec.ordre,
         lcur_int_meter_rec.num_apa, null, ls_num_apa,
         lcur_int_meter_rec.nis_rad, 'MC999', 'ML001', ls_tip_apa, 'AP011',
         'PA003', lcur_int_meter_rec.f_fact, 1,
         lcur_int_meter_rec.f_fact - 30, 1, 1, lf_lvto);
    end loop;
  
    ll_same     := 0;
    ls_num_apa  := ' ';
    ls_co_marca := ' ';
  
    --check for duplicates. 
    declare
      cursor lcur_duplicate is
        select m.*, m.rowid
          from int_meter m
         where (m.num_apa, m.co_marca) in
               (select num_apa, co_marca
                  from int_meter
                 group by num_apa, co_marca
                having count(*) between 2 and 10)
         order by m.num_apa, m.co_marca, f_lvto desc;
      lb_loop         boolean := true;
      ls_co_marca_dup varchar2(5) := ' ';
    begin
      while lb_loop loop
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
                                 and cod_mask <> 0
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
      end loop;
    end;
  end cp2_int_meter_galatee;

  /***
  *
  */
  procedure cp3_apmedida_ap is
    cursor lcur_apmedida_ap is
      select * from int_meter order by nis_rad;
    --ls_num_lote varchar2(15) := '301300000000001';
  begin
    for lcur_apmedida_ap_rec in lcur_apmedida_ap loop
    
      /*insert into apmedida_ap
      ()
      values
      ();*/
    
      null;
    end loop;
  end cp3_apmedida_ap;

  procedure p06_readings_cleanup is
    /**
     * TML - 2013-09-20
     * Readings Module   
     *  
     *
    */
  begin
    update apmedida_co co
       set tip_lect = 'RA003'
     where (nis_rad, f_fact, tip_csmo) in
           (select nis_rad, min(f_fact), tip_csmo
              from apmedida_co
             where nis_rad = co.nis_rad
               and tip_csmo = co.tip_csmo
             group by nis_rad, tip_csmo);
  
    commit;
  
    begin
    
      update apmedida_co set num_rue = 4 where num_rue < 4;
    
      for x in (select *
                  from (select nis_rad, num_apa, co_marca,
                                max(length(lect)) len, num_rue
                           from apmedida_co
                          group by nis_rad, num_apa, co_marca, num_rue)
                 where len > num_rue) loop
      
        update apmedida_co
           set num_rue = x.len
         where nis_rad = x.nis_rad
           and num_apa = x.num_apa
           and co_marca = x.co_marca;
      
      end loop;
    end;
  
    declare
      cursor ix is
        select nis_rad, num_apa, co_marca, num_rue,
               max(length(lect)) new_num_rue
          from apmedida_co
         where nis_rad in
               (select nis_rad from apmedida_co where num_rue < length(lect))
         group by nis_rad, num_apa, co_marca, num_rue;
    begin
      for x in ix loop
        if x.num_rue < 4 then
          x.num_rue := 4;
        end if;
      
        update apmedida_co
           set num_rue = x.new_num_rue
         where nis_rad = x.nis_rad
           and num_apa = x.num_apa
           and co_marca = x.co_marca;
      end loop;
    
      for k in (select nis_rad, num_apa, co_marca, max(num_rue) num_rue
                  from apmedida_co co
                 where exists (select num_rue
                          from apmedida_co
                         where num_apa = co.num_apa
                           and co_marca = co.co_marca
                           and num_rue <> co.num_rue)
                 group by nis_rad, num_apa, co_marca) loop
      
        update apmedida_co
           set num_rue = k.num_rue
         where nis_rad = k.nis_rad
           and num_apa = k.num_apa
           and co_marca = k.co_marca;
      
      end loop;
    
      for p in (select distinct pa.rowid, co.nis_rad, co.num_apa, co.co_marca,
                                co.num_rue
                  from apmedida_co co, apmedida_param pa
                 where co.num_apa = pa.num_apa
                   and co.co_marca = pa.co_marca
                   and co.num_rue <> pa.num_rue) loop
      
        update apmedida_param
           set num_rue = p.num_rue
         where rowid = p.rowid;
      
      end loop;
    end;
    commit;
  end p06_readings_cleanup;

  procedure cp3_apmedida_co is
    cursor lcur_ap_co is
      select *
        from (select centre, client, ordre, a.nis_rad, sec_nis,
                      cod_unicom_serv, cod_cli, nif, point, compteur,
                      a.num_apa, a.co_marca, f_fact, lect, tfac, coeflect,
                      num_apa_curr, cadcompt, facture, csmo, dif_lect,
                      'AP_AP' table_name, a.tip_apa, a.f_inst
                 from galatee_readings g, apmedida_ap a
                where exists (select 0
                         from recibos
                        where nis_rad = g.nis_rad
                          and num_fact = g.facture)
                  and not exists (select 0
                         from apmedida_co
                        where nis_rad = a.nis_rad
                          and num_apa = a.num_apa
                          and co_marca = a.co_marca)
                  and g.nis_rad = a.nis_rad
                  and num_apa_curr = 'CURR'
               union all
               select centre, client, ordre, a.nis_rad, sec_nis,
                      cod_unicom_serv, cod_cli, nif, point, compteur,
                      a.num_apa, a.co_marca, f_fact, lect, tfac, coeflect,
                      num_apa_curr, cadcompt, facture, csmo, dif_lect,
                      'HAP_AP' table_name, a.tip_apa, a.f_inst
                 from galatee_readings g, hapmedida_ap a
                where exists (select 0
                         from recibos
                        where nis_rad = g.nis_rad
                          and num_fact = g.facture)
                  and not exists (select 0
                         from hapmedida_co
                        where nis_rad = a.nis_rad
                          and num_apa = a.num_apa
                          and co_marca = a.co_marca)
                  and g.nis_rad = a.nis_rad
                  and g.num_apa = a.num_apa
                  and num_apa_curr <> 'CURR')
       order by nis_rad, table_name;
    type lt_reading_param is table of number index by varchar2(5);
    ll_cte      number;
    ll_param    number;
    ll_commit   number;
    ll_num_rue  number;
    ll_nis_rad  number;
    ls_tip_csmo varchar2(5);
    ls_tip_lect varchar2(5);
    lt_params   lt_reading_param;
  begin
    ll_commit  := 0;
    ll_nis_rad := 0;
  
    for lcur_readings_rec in lcur_ap_co loop
    
      if lcur_readings_rec.point = 1 and
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
      end if;
    
      ll_cte     := nvl(lcur_readings_rec.coeflect, 1);
      ll_num_rue := nvl(lcur_readings_rec.cadcompt, 4);
    
      if ll_cte <= 0 then
        ll_cte := 1;
      end if;
    
      if ll_num_rue < 4 then
        ll_num_rue := 4;
      end if;
    
      if ll_nis_rad != lcur_readings_rec.nis_rad then
        lt_params.delete();
        ll_commit := ll_commit + 1;
      end if;
    
      begin
        ll_param := lt_params(ls_tip_csmo);
      exception
        when no_data_found then
          ll_param := 0;
      end;
    
      ls_tip_lect := 'RA005';
    
      if lcur_readings_rec.table_name = 'AP_AP' and ll_param = 0 then
      
        insert into apmedida_param
          (usuario, f_actual, programa, num_apa, co_marca, f_val, tip_csmo,
           coef_per, cte_prim, cte_secund, peso_entr, peso_sal, num_rue)
        values
          (gls_usuario, trunc(sysdate), gls_programa,
           lcur_readings_rec.num_apa, lcur_readings_rec.co_marca,
           lcur_readings_rec.f_inst, ls_tip_csmo, 0, ll_cte, 1, 0, 0,
           ll_num_rue);
      
        lt_params(ls_tip_csmo) := 1;
      
      end if;
    
      if lcur_readings_rec.dif_lect > 99999999 then
        lcur_readings_rec.dif_lect := lcur_readings_rec.csmo;
      end if;
    
      if lcur_readings_rec.table_name = 'AP_AP' then
        begin
          insert into apmedida_co
            (usuario, f_actual, programa, nis_rad, num_apa, co_marca,
             tip_csmo, lect, f_lect, csmo, cte, tip_lect, f_fact, dif_lect,
             sec_rec, num_rue, sec_lect, lect_ant, f_trat, co_al, cod_emp,
             time_lect)
          values
            (gls_usuario, trunc(sysdate), gls_programa,
             lcur_readings_rec.nis_rad, lcur_readings_rec.num_apa,
             lcur_readings_rec.co_marca, ls_tip_csmo, lcur_readings_rec.lect,
             lcur_readings_rec.f_fact, lcur_readings_rec.csmo, ll_cte,
             ls_tip_lect, lcur_readings_rec.f_fact,
             lcur_readings_rec.dif_lect, 0, ll_num_rue, 0, 0,
             lcur_readings_rec.f_fact, 'AN000', 0, 0);
        
        exception
          when dup_val_on_index then
            null;
          when others then
            dbms_output.put_line(sqlerrm || ':' ||
                                 lcur_readings_rec.nis_rad || ' : ' ||
                                 to_char(lcur_readings_rec.f_fact,
                                         'yyyymmdd'));
        end;
      
      else
      
        begin
          insert into hapmedida_co
            (usuario, f_actual, programa, nis_rad, num_apa, co_marca,
             tip_csmo, lect, f_lect, csmo, cte, tip_lect, f_fact, dif_lect,
             sec_rec, num_rue, sec_lect, lect_ant, f_trat, co_al, cod_emp,
             time_lect)
          values
            (gls_usuario, trunc(sysdate), gls_programa,
             lcur_readings_rec.nis_rad, lcur_readings_rec.num_apa,
             lcur_readings_rec.co_marca, ls_tip_csmo, lcur_readings_rec.lect,
             lcur_readings_rec.f_fact, lcur_readings_rec.csmo, ll_cte,
             ls_tip_lect, lcur_readings_rec.f_fact,
             lcur_readings_rec.dif_lect, 0, ll_num_rue, 0, 0,
             lcur_readings_rec.f_fact, 'AN000', 0, 0);
        exception
          when dup_val_on_index then
            null;
          when others then
            dbms_output.put_line(sqlerrm || ':' ||
                                 lcur_readings_rec.nis_rad || ' : ' ||
                                 to_char(lcur_readings_rec.f_fact,
                                         'yyyymmdd'));
          
        end;
      
      end if;
    
      ll_nis_rad := lcur_readings_rec.nis_rad;
    
      if mod(ll_commit, 1000) = 0 then
        commit;
      end if;
    
    end loop;
  
    commit;
    p06_readings_cleanup;
    commit;
  
  end cp3_apmedida_co;

end pck_conversion_apmedida;
/
