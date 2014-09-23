--create table xaixai_balances as
select tr.zona, tr.instalacao, codoperacao, mes_ano, datavalor, valor, cobranca, tr.iva, tr.taxaradio, tr.taxafixa, tr.taxalixo
  from edmaccess.transitado tr, edmaccess.consumidores co
 where cobranca < valor
 and codoperacao not in (504, 651, 503, 650)
 and tr.zona = co.zona
 and tr.instalacao = co.no_da_instalacao
 and co.activo = 1
 and co.zona != 100
 --and tr.valor < 0
 --and tr.instalacao = 37950 and tr.zona = 4
 --and tr.codoperacao = 631
 --and tr.valor > 0 
 and not exists (select 0 from edmaccess.transitado where zona = tr.zona and instalacao = tr.instalacao /*and mes_ano = tr.mes_ano*/ and 
 -valor = tr.valor and codoperacao = tr.codoperacao)
order by tr.zona, tr.instalacao, mes_ano
