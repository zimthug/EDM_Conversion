begin
  for x in (select lpad(centre, 2, 0) || '-' || client folio, aa.nis_rad
              from int_supply sp, account_assoc aa
             where sp.nis_rad = aa.nis_rad_sub
               and system_id = '02') loop
               
    update rel_nis_rutafol
       set folio = x.folio, ref_num = x.folio
     where nis_rad = x.nis_rad;
     
  end loop;
end;
