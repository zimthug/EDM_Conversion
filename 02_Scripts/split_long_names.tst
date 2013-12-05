PL/SQL Developer Test script 3.0
18
declare 
  cursor ix is
  select * from client where length(nomabon) > 25
 and rownum <= 50;
 ls_name_rev varchar2(50);
begin
  for x in ix loop
    
    for i in reverse 1..length(x.nomabon) loop
      
      if substr(x.nomabon, i, 1) = ' ' then
        dbms_output.put_line(x.nomabon||' >>> '||substr(x.nomabon, 1, i)||' + ' ||substr(x.nomabon, i, 50));
        exit;
      end if;
      
    end loop;
  end loop;
end;
0
0
