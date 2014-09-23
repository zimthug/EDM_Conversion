declare
  s                        number;
  p                        number;
  digitos                  varchar2(100);
  entidade                 varchar2(8) := '20003';
  montante                 varchar2(100) := '280012';
  referenciaSemCheckDigito varchar2(20) := '003023801';
begin
  p       := 0;
  s       := 0;
  digitos := entidade || referenciaSemCheckDigito || montante;
  for i in 1..length(digitos) loop
    s := substr(digitos, i, 1) + p;
    p := mod((s * 10) , 97);
  end loop;
  p := mod((p * 10) , 97);
  dbms_output.put_line(98 - p);
end;
