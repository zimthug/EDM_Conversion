declare
  cursor lcur_callejero is
    select cod_calle, cod_local,
           lpad(row_number()
                 over(partition by cod_local order by cod_calle nulls last), 4,
                 0) nas_cod, rowid
      from callejero ca
     order by cod_local, 3;
begin
  for lcur_callejero_rec in lcur_callejero loop
    update callejero
       set nas_code = lcur_callejero_rec.nas_cod
     where rowid = lcur_callejero_rec.rowid;
  end loop;
end;
/

declare cursor lcur_fincas is
  select nif, num_puerta, duplicador, ca.cod_calle,
         '0000' || lpad(row_number() over(partition by ca.cod_calle order by
                              num_puerta, nif nulls last), 5, 0) ||
          lpad(ca.nas_code, 4, 0) || lpad(lo.nas_code, 4, 0) new_cod_nas,
         fi.rowid
    from callejero ca, localidades lo, fincas fi
   where ca.cod_calle = fi.cod_calle
     and ca.cod_local = lo.cod_local
  --and ca.cod_calle = 687
   order by cod_calle, num_puerta, nif;
ll number := 0;
begin
  for lcur_fincas_rec in lcur_fincas loop
  
    begin
      update fincas f
         set f.cod_nas = lcur_fincas_rec.new_cod_nas,
             f.numero_aux = substr(lcur_fincas_rec.new_cod_nas, 1, 9)
       where rowid = lcur_fincas_rec.rowid;
    exception
      when dup_val_on_index then
      
        ll := ll + 1;
      
        lcur_fincas_rec.new_cod_nas := lpad(ll, 4, 0) ||
                                       substr(lcur_fincas_rec.new_cod_nas, 5);
      
        begin
          update fincas f
             set f.cod_nas = lcur_fincas_rec.new_cod_nas,
                 f.numero_aux = substr(lcur_fincas_rec.new_cod_nas, 1, 9)
           where rowid = lcur_fincas_rec.rowid;
           
        exception
          when dup_val_on_index then
            
             lcur_fincas_rec.new_cod_nas := lpad(ll, 5, 0) ||
                                       substr(lcur_fincas_rec.new_cod_nas, 6);
                                       
            update fincas f
             set f.cod_nas = lcur_fincas_rec.new_cod_nas,
                 f.numero_aux = substr(lcur_fincas_rec.new_cod_nas, 1, 9)
           where rowid = lcur_fincas_rec.rowid;
        end;
      
        if mod(ll, 9999) = 0 then
          ll := 1;
        end if;
      
    end;
  
  end loop;
  --commit;
end;
/
