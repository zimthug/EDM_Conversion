create table tmp_matched_xaixai_postpaid as
select c.zona, c.no_da_instalacao, b.no_do_contador, a.bocl_nocontador,
       a.bocl_contratonumero, a.bocl_titular, c.nome, a.bobr_idbairro
  from edmaccess.consumidores c, edmcamp.cadastramento_new a,
       edmaccess.contador b
 where /*c.no_da_instalacao = a.bocl_contratonumero
   and*/
 c.no_da_instalacao = b.no_da_instalacao
 and c.zona = b.zona
 and a.bocl_nocontador =
 nvl(substr(b.no_do_contador, 1, instr(b.no_do_contador, '/') - 1),
     b.no_do_contador)
 and boad_idarea = 3
 and length(bocl_nocontador) > 4
 order by 3
