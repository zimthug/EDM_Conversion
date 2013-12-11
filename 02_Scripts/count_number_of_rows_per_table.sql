declare
  i number;
begin
  for x in (select * from all_tables where owner in ('SGC', 'INTFOPEN')) loop
    execute immediate 'select count(*) from ' || x.owner || '.' ||
                      x.table_name
      into i;
  
    dbms_output.put_line(x.owner || chr(9) || x.table_name || chr(9) || i);
  
  end loop;
end;
