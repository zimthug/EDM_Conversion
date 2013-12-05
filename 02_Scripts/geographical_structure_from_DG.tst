PL/SQL Developer Test script 3.0
134
declare
  cursor lcur_deptos is
    select distinct cod_pro,
                    trim(regexp_replace(prov, '[[:punct:]]', null)) prov
      from edmgalatee.dg_geostruct
     where cod_pro in (10, 11);

  cursor lcur_munic(pll_cod_pro in number) is
    select distinct cod_dist, distrito
      from edmgalatee.dg_geostruct
     where cod_pro = pll_cod_pro
     order by 2;

  cursor lcur_localidade(pll_cod_dist in number) is
    select distinct e.cod_pa, e.pa, e.cod_loc, e.loc,
                    pa || case
                      when loc = pa then
                       null
                      else
                       ' - ' || loc
                    end localidade
      from edmgalatee.dg_geostruct e
     where cod_dist = pll_cod_dist
     order by 1;

  cursor lcur_callejero(pll_cod_pa in number, pll_cod_loc in number) is
    select distinct e.cod_bairro, e.bairro, e.cod_unicom
      from edmgalatee.dg_geostruct e
     where cod_pa = pll_cod_pa
       and cod_loc = pll_cod_loc;

  ll_cod_depto  number;
  ll_cod_munic  number;
  ll_cod_local  number;
  ll_cod_calle  number;
  ll_cod_unicom number;
  ll_cod_prov   number := 2;
  ls_usuario    varchar2(15) := 'EDM_CONV';
  ls_programa   varchar2(15) := 'EDM_CONV';
begin
  select nvl(max(cod_depto), 9) into ll_cod_depto from intfopen.deptos;

  select nvl(max(cod_munic), 99)
    into ll_cod_munic
    from intfopen.municipios;

  select nvl(max(cod_local), 999)
    into ll_cod_local
    from intfopen.localidades;

  select nvl(max(cod_calle), 50) into ll_cod_calle from intfopen.callejero;

  for lcur_deptos_rec in lcur_deptos loop
  
    ll_cod_depto := ll_cod_depto + 1;
  
    insert into intfopen.deptos
      (usuario, f_actual, programa, cod_prov, cod_depto, nom_depto,
       nom_depto_arab)
    values
      (ls_usuario, trunc(sysdate), ls_programa, ll_cod_prov, ll_cod_depto,
       upper(lcur_deptos_rec.prov), ' ');
  
    update edmgalatee.dg_geostruct a
       set cod_depto = ll_cod_depto
     where a.cod_pro = lcur_deptos_rec.cod_pro;
  
    for lcur_munic_rec in lcur_munic(lcur_deptos_rec.cod_pro) loop
    
      ll_cod_munic := ll_cod_munic + 1;
    
      insert into intfopen.municipios
        (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
         nom_munic, nas_code, nom_munic_arab)
      values
        (ls_usuario, trunc(sysdate), ls_programa, ll_cod_prov, ll_cod_depto,
         ll_cod_munic, upper(lcur_munic_rec.distrito), ' ', ' ');
    
      update edmgalatee.dg_geostruct a
         set a.cod_munic = ll_cod_munic
       where a.cod_dist = lcur_munic_rec.cod_dist;
    
      for lcur_localidade_rec in lcur_localidade(lcur_munic_rec.cod_dist) loop
      
        ll_cod_local := ll_cod_local + 1;
      
        insert into intfopen.localidades
          (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
           cod_local, nom_local, area_ejec, nas_code, nom_local_arab)
        values
          (ls_usuario, trunc(sysdate), ls_programa, ll_cod_prov,
           ll_cod_depto, ll_cod_munic, ll_cod_local,
           upper(trim(lcur_localidade_rec.localidade)), 0, ll_cod_local, ' ');
      
        update edmgalatee.dg_geostruct a
           set a.cod_local = ll_cod_local
         where a.cod_pa = lcur_localidade_rec.cod_pa
           and a.cod_loc = lcur_localidade_rec.cod_loc;
      
        for lcur_callejero_rec in lcur_callejero(lcur_localidade_rec.cod_pa,
                                                 lcur_localidade_rec.cod_loc) loop
        
          ll_cod_calle := ll_cod_calle + 1;
        
          if lcur_callejero_rec.cod_unicom is null then
            ll_cod_unicom := 8011;
          end if;
        
          insert into intfopen.callejero
            (usuario, f_actual, programa, cod_calle, cod_prov, cod_depto,
             cod_munic, cod_local, nom_calle, tip_via, cod_unicom,
             cod_oficom, ind_urb_rur, cod_post, cod_centec, tip_via2,
             nas_code, nom_calle_arab, ifs_dep_code)
          values
            (ls_usuario, trunc(sysdate), ls_programa, ll_cod_calle,
             ll_cod_prov, ll_cod_depto, ll_cod_munic, ll_cod_local,
             upper(trim(lcur_callejero_rec.bairro)), 'TV209', ll_cod_unicom,
             ll_cod_unicom, 1, ' ', ll_cod_unicom, ' ', ll_cod_calle, ' ', 0);
        
          update edmgalatee.dg_geostruct a
             set a.cod_calle = ll_cod_calle
           where a.cod_bairro = lcur_callejero_rec.cod_bairro;
        
        end loop;      
      end loop;      
    end loop;  
  end loop;  
end;

--select * from deptos;

--select * from municipios where programa = 'EDM_CONV'

--select * from edmgalatee.dg_geostruct where cod_munic is not null
0
0
