declare
  cursor ix is
    select a.*, 'CONV_EDM' usuario, 'CONV_EDM' programa,
           trunc(sysdate) f_actual, a.rowid
      from tmp_xaixai_geo_new a
     order by distrito, municipio, bairro, vias;
  ll_via        number;
  ll_cod_prov   number := 12;
  ll_cod_depto  number;
  ll_cod_munic  number;
  ll_cod_local  number;
  ll_cod_calle  number;
  ll_cod_unicom number;
  ls_tip_via    varchar2(5);
  ls_distrito   varchar2(50) := ' ';
  ls_municipio  varchar2(50) := ' ';
  ls_bairro     varchar2(50) := ' ';
  ls_nom_calle  varchar2(50) := ' ';
begin
  select nvl(max(cod_depto), 99) into ll_cod_depto from deptos;

  select nvl(max(cod_munic), 999) into ll_cod_munic from municipios;

  select nvl(max(cod_local), 999) into ll_cod_local from localidades;

  select nvl(max(cod_calle), 99999) into ll_cod_calle from callejero;

  for x in ix loop
    if ls_distrito != x.distrito then
      ll_cod_depto := ll_cod_depto + 1;
    
      insert into deptos
        (usuario, f_actual, programa, cod_prov, cod_depto, nom_depto,
         nom_depto_arab)
      values
        (x.usuario, x.f_actual, x.programa, ll_cod_prov, ll_cod_depto,
         trim(x.distrito), trim(x.distrito));
    end if;
  
    if ls_municipio != x.municipio then
      ll_cod_munic := ll_cod_munic + 1;
    
      insert into municipios
        (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
         nom_munic, nas_code, nom_munic_arab)
      values
        (x.usuario, x.f_actual, x.programa, ll_cod_prov, ll_cod_depto,
         ll_cod_munic, x.municipio, ' ', x.municipio);
    end if;
  
    if ls_bairro != x.bairro then
    
      ll_cod_local := ll_cod_local + 1;
    
      insert into localidades
        (usuario, f_actual, programa, cod_prov, cod_depto, cod_munic,
         cod_local, nom_local, area_ejec, nas_code, nom_local_arab)
      values
        (x.usuario, x.f_actual, x.programa, ll_cod_prov, ll_cod_depto,
         ll_cod_munic, ll_cod_local, x.bairro, 0, 1000, x.bairro);
    
      if x.taxa_de_lixo = 'Pagam taxa de Lixo' then
        insert into municipios_lixo
          (usuario, f_actual, programa, cod_munic, cod_tar, f_val, f_anul,
           co_concepto, rango_minimo, rango_maximo, prec_concepto)
        values
          (x.usuario, x.f_actual, x.programa, ll_cod_local, 'E01',
           to_date(19700101, 'yyyymmdd'), to_date(29991231, 'yyyymmdd'),
           'CC130', 0, 999999, 20);
      end if;
    
    end if;
  
    if x.vias is not null then
      ll_via := 2;
    else
      ll_via := 1;
    end if;
  
    ll_cod_unicom := null;
  
    if x.agencia = 'AGENCIA DE XAI-XAI' then
      ll_cod_unicom := 7100;
    elsif x.agencia = 'AGENCIA DE CHIBUTO (ZSC)' then
      ll_cod_unicom := 7102;
    elsif x.agencia = 'AGENCIA DE MANJACAZE (ZSC)' then
      ll_cod_unicom := 7103;
    end if;
  
    for i in 1 .. ll_via loop
      ll_cod_calle := ll_cod_calle + 1;
    
      if i = 2 then
        ls_tip_via   := 'TV002';
        ls_nom_calle := x.vias;
      else
        ls_tip_via   := 'TV008';
        ls_nom_calle := x.bairro;
      
        update tmp_xaixai_geo_new
           set cod_calle = ll_cod_calle
         where rowid = x.rowid;
      end if;
    
      insert into callejero
        (usuario, f_actual, programa, cod_calle, cod_prov, cod_depto,
         cod_munic, cod_local, nom_calle, tip_via, cod_unicom, cod_oficom,
         ind_urb_rur, cod_post, cod_centec, tip_via2, nas_code,
         nom_calle_arab, ifs_dep_code)
      values
        (x.usuario, x.f_actual, x.programa, ll_cod_calle, ll_cod_prov,
         ll_cod_depto, ll_cod_munic, ll_cod_local, ls_nom_calle, ls_tip_via,
         ll_cod_unicom, ll_cod_unicom,
         decode(x.taxa_de_lixo, 'Pagam taxa de Lixo', 1, 2), 0,
         ll_cod_unicom, ls_tip_via, 0001, ls_nom_calle, 0);
    
    end loop;
  
    ls_distrito  := x.distrito;
    ls_municipio := x.municipio;
    ls_bairro    := x.bairro;
  end loop;
end;
