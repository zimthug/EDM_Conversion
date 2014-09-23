begin
  for x in (select a.bocl_telemovel_1, a.bocl_telemovel_2, a.bocl_xcoord,
                   a.bocl_ycoord, c.msno, cod_cli, nif
              from edmcamp.cadastramento_new a, edmeclipse.customer_data c,
                   int_supply s
             where lpad(a.bocl_nocontador, 11, 0) = c.msno
               and c.msno = s.client) loop
  
    update clientes o
       set o.tfno_cli = nvl(x.bocl_telemovel_1, ' '),
           o.tfno2_cli = nvl(x.bocl_telemovel_2, ' ')
     where cod_cli = x.cod_cli;
  
    update fincas f
       set f.gis_x = x.bocl_xcoord, f.gis_y = x.bocl_ycoord
     where nif = x.nif;
  
  end loop;
end;
/

begin
  for x in (select a.bocl_telemovel_1, a.bocl_telemovel_2, a.bocl_xcoord,
                   a.bocl_ycoord, cod_cli, nif
              from edmcamp.cadastramento_new a, edmaccess.contador c,
                   int_supply s
             where a.bocl_nocontador = c.no_do_contador
             and length(c.no_do_contador) > 3
               and c.no_da_instalacao = s.client
               and c.zona = centre) loop
  
    update clientes o
       set o.tfno_cli = nvl(x.bocl_telemovel_1, ' '),
           o.tfno2_cli = nvl(x.bocl_telemovel_2, ' ')
     where cod_cli = x.cod_cli;
  
    update fincas f
       set f.gis_x = x.bocl_xcoord, f.gis_y = x.bocl_ycoord
     where nif = x.nif;
  
  end loop;
end;
/


--select * from clientes
