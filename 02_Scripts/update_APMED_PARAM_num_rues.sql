declare
  cursor ix is
    select sp.nis_rad, sp.sec_nis, ca.centre, ca.ag, ca.compteur,
           coefcomptage, ca.point,
           decode(point, 1, 'CO111', 2, 'CO551', 3, 'CO331') tip_csmo
      from edmgalatee.canalisation ca, int_supply sp
     where coefcomptage > 0
       and ca.centre = sp.centre
       and ca.ag = sp.client
       and sp.nis_rad is not null;
begin
  for x in ix loop
    update apmedida_param
       set num_rue = num_rue + (x.coefcomptage * .1)
     where (num_apa, co_marca) in
           (select num_apa, co_marca
              from apmedida_co
             where nis_rad = x.nis_rad)
       and tip_csmo = x.tip_csmo;
  end loop;
end;

/*

select *
  from apmedida_param
 where (num_apa, co_marca) in
       (select num_apa, co_marca from apmedida_ap where nis_rad = 200048990);
       
       */
