declare
  cursor ix is
    select a.*, b.num_apa, b.co_marca, b.f_inst,
           decode(point, 1, 'CO111', 2, 'CO551', 3, 'CO331') tip_csmo
      from tmp_december_reads a, apmedida_ap b
     where a.nis_rad in
           (select nis_rad
              from itifact_vo_apa it
             where not exists (select 0
                      from apmedida_co
                     where nis_rad = it.nis_rad
                       and num_apa = it.num_apa
                       and co_marca = it.co_marca
                       and tip_csmo = it.tip_csmo))
       and nindex = (select max(nindex)
                       from tmp_december_reads
                      where nis_rad = a.nis_rad
                        and point = a.point)
       and a.nis_rad = b.nis_rad;
  lf_alta date;
begin
  for x in ix loop
    select f_alta into lf_alta from sumcon where nis_rad = x.nis_rad;
  
    if lf_alta > x.dfac - 30 then
    
      dbms_output.put_line(x.nis_rad || '   ' ||
                           to_char(x.dfac - 30, 'yyyy-mm-dd') || '    ' ||
                           to_char(lf_alta, 'yyyy-mm-dd'));
      lf_alta := x.dfac - 30;
      update sumcon
         set f_alta = lf_alta, f_alta_cont = lf_alta
       where nis_rad = x.nis_rad;
    
    end if;
  
    update apmedida_ap set f_inst = x.dfac - 30 where nis_rad = x.nis_rad;
  
    update puntomed_param
       set f_val = x.dfac - 30
     where nis_rad = x.nis_rad;
  
    update apmedida_param
       set f_val = lf_alta
     where (num_apa, co_marca) in
           (select num_apa, co_marca
              from apmedida_ap
             where nis_rad = x.nis_rad);
  
    begin
      insert into apmedida_co
        (usuario, f_actual, programa, nis_rad, num_apa, co_marca, tip_csmo,
         lect, f_lect, csmo, cte, tip_lect, f_fact, dif_lect, sec_rec,
         num_rue, sec_lect, lect_ant, f_trat, co_al, cod_emp, time_lect)
      values
        ('CONV_EDM', trunc(sysdate), 'CONV_EDM', x.nis_rad, x.num_apa,
         x.co_marca, x.tip_csmo, x.aindex, x.dfac - 30, 0, x.coeflect,
         'RA003', x.dfac - 30, 0, 0, 5, 0, 0, x.dfac - 30, 'AN000', 0, 0);
    exception
      when dup_val_on_index then
        null;
    end;
  end loop;
end;

--201332085

/*select f_alta, f_alta_cont from  sumcon where nis_rad = 201373740;

select * from apmedida_ap where nis_rad = 201373740;

select * from apmedida_co where nis_rad = 201373740;*/

/*
201373740   2013-12-03    2013-12-10
201373187   2013-12-11    2013-12-23
*/
