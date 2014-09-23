create table tmp_matched_xaixai_prepaid as
select c.centre, c.client, a.bocl_nocontador,
       a.bocl_titular, c.nomabon, a.bobr_idbairro
  from int_supply c, edmcamp.cadastramento_new a
 where c.client = lpad(a.bocl_nocontador, 11, 0)
 order by 3
