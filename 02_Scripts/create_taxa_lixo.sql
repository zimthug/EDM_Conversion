declare
  cursor ix is
    select m.*, t.f_val, t.f_anul
      from map_lixos m, tarifas t
     where m.cod_tar = t.cod_tar
       and cod_munic = 'MATOLA';

begin
  for x in ix loop
    for c in (select *
                from municipios
               where cod_depto in
                     (select cod_depto
                        from deptos
                       where nom_depto in
                             ('MAPUTO PROVINCIA', 'Maputo Prov¿ncia'))) loop
    
      insert into sgc.municipios_lixo
        (usuario, f_actual, programa, cod_munic, cod_tar, f_val, f_anul,
         co_concepto, rango_minimo, rango_maximo, prec_concepto)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', c.cod_munic, x.cod_tar,
         x.f_val, x.f_anul, 'CC130', x.minimo, x.maximo, x.prec_concepto);
    end loop;
  end loop;
end;
