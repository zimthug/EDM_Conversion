delete grupos_rel where cod_grupo like 'PT___' and cod_mask = 2048;

insert into grupos_rel
  select *
    from (select distinct 'CONV_EDM' usuario, trunc(sysdate) f_actual, 'CONV_EDM' programa,
                           'PT008' cod_grupo, cod_munic codigo, 2048
             from municipios_lixo
           union
           select distinct 'CONV_EDM', trunc(sysdate), 'CONV_EDM',
                           'PT009' cod_grupo, cod_local codigo, 2048
             from localidades l
            where not exists
            (select 0 from municipios_lixo where cod_munic = l.cod_munic)) ab
   where not exists (select 0
            from grupos_rel
           where cod_grupo = ab.cod_grupo
             and codigo = to_char(ab.codigo))
