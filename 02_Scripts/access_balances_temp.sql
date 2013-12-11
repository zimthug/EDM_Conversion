create table tmp_access_balances as
 select t.zona centre, t.instalacao client, sum(t.valor) amount
      from edmaccess.transitado t
     where not exists (select *
              from edmaccess.contabilistico c
             where t.zona = c.zona
               and t.instalacao = c.instalacao
               and t.mes_ano = c.mes_ano
               and t.codoperacao = c.codoperacao)
       and exists
     (select 0
              from int_supply
             where centre = t.zona
               and client = t.instalacao)
       and t.codigotransacao = 1
       and t.codoperacao in (select codoperacao from edmaccess.debito)
     group by t.zona, t.instalacao;
     

declare
  cursor ix is
    select t.*, s.rowid from tmp_access_balances t, int_supply s
     where t.centre = s.centre
     and t.client = s.client;
begin
  for x in ix loop
  
    update int_supply
       set imp_tot_rec = x.amount
     where rowid = x.rowid;
  
  end loop;
  commit;
end;
/
