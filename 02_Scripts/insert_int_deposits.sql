insert into int_deposits
  select centre, client, ordre, min(l.denr) deposit_date,
         sum(montant) deposit
    from edmgalatee.lclient l
   where coper = '070'
     and exists (select 0
            from int_supply
           where centre = l.centre
             and client = l.client
             and ordre = l.ordre
             and est_sum = 'EC012')
   group by centre, client, ordre;

commit;
