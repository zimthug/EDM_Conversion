declare
  l_ref_code varchar2(20);
begin
  for x in (select rowid
              from sumcon
             where trim(num_ident_sipo) is null
               and tip_suministro != 'SU900'
               and cod_mask != 2048) loop
    select to_char(sgc.seq_referencia_edm.nextval, '0000000')
      into l_ref_code
      from dual;
  
    update sumcon set num_ident_sipo = l_ref_code where rowid = x.rowid;
  
  end loop;
end;
/

/*select num_ident_sipo, count(*)
              from sumcon
             where tip_suministro != 'SU900'
               and cod_mask != 2048 group by num_ident_sipo having count(*) > 1*/

declare cursor ix is
  select su.nis_rad,
         lpad(su.num_ident_sipo, 7, 0) || to_char(f_fact, 'mm') referenciaSemCheckDigito,
         replace(to_char(round(imp_tot_rec, 2)), '.') montante, imp_tot_rec,
         f_fact, re.rowid
    from sumcon su, recibos re
   where su.nis_rad = re.nis_rad
     and ind_conversion = 1
     and trim(su.num_ident_sipo) is not null
     and su.num_ident_sipo = '0004096';
s number;
p number;
ls_digitos varchar2(100);
ls_entidade varchar2(10) := '20002';
begin
  for lcur_rec in ix loop
    p          := 0;
    s          := 0;
    ls_digitos := ls_entidade || lcur_rec.referenciaSemCheckDigito ||
                  lcur_rec.montante;
    for i in 1 .. length(ls_digitos) loop
      s := substr(ls_digitos, i, 1) + p;
      p := mod((s * 10), 97);
    end loop;
    p := mod((p * 10), 97);
  
    update recibos r
       set r.num_ident_sipo = lcur_rec.referenciaSemCheckDigito ||
                               lpad(to_number(98 - p), 2, 0)
     where rowid = lcur_rec.rowid;
  
  /*dbms_output.put_line(lcur_rec.referenciaSemCheckDigito || ' ' || ' - ' ||
                             lpad(to_number(98 - p), 2, 0) || ' -> ' ||
                             lcur_rec.referenciaSemCheckDigito ||
                             lpad(to_number(98 - p), 2, 0));*/
  end loop;
end;
/
