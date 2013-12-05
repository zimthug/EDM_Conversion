with bill_data as
 (select e.facture, e.centre, e.client, e.ordre, dfac, e.periode, e.totftax,
         e.totfttc bill_amount, e.totfht, r.redevance, r.tranche, r.redht,
         r.redtaxe
    from edmgalatee.centfac e, edmgalatee.credfac r
   where e.centre = r.centre
     and e.client = r.client
     and e.ordre = r.ordre
     and e.facture = r.facture
     and e.client = '0101118'
     and e.centre = '010'
  /*and e.facture = '355289'*/
  ),
trans_data as
 (select sum(decode(dc, 'D', montant, -montant)) montant, l.centre, l.client,
         l.ordre, l.ndoc
    from edmgalatee.lclient l
   where dc = 'C'
      or (dc = 'D' and coper in ('078', '080'))
   group by l.centre, l.client, l.ordre, l.ndoc)
select a.*, montant
  from bill_data a, trans_data b
 where a.client = b.client(+)
   and a.centre = b.centre(+)
   and a.ordre = b.ordre(+)
   and a.facture = b.ndoc(+)
