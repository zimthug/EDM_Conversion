--create table galatee_readings tablespace datos as
insert into galatee_readings
  select cp.centre, cp.client, cp.ordre, sp.nis_rad, sp.sec_nis,
         sp.cod_unicom_serv, sp.cod_cli, sp.nif, cp.point, cp.compteur,
         case
           when substr(trim(cp.compteur), 1, 1) in ('R', 'D') then
            'A' || substr(trim(cp.compteur), 2)
           else
            trim(cp.compteur)
         end num_apa, re.f_fact, nindex lect, tfac, cp.coeflect,
         decode(ca.compteur, null, 'OLD', 'CURR') num_apa_curr, ca.cadcompt,
         facture, cp.conso csmo,
         decode(cp.point, 2, nindex, cp.nindex - cp.aindex) dif_lect
    from edmgalatee.cprofac cp, recibos re, int_supply sp,
         edmgalatee.canalisation ca
   where cp.centre = sp.centre
     and cp.client = sp.client
     and cp.ordre = sp.ordre
     and sp.nis_rad = re.nis_rad
     and re.num_fact = cp.facture
     and cp.centre = ca.centre(+)
     and cp.client = ca.ag(+)
     and cp.compteur = ca.compteur(+)
     and re.tip_rec = 'TR110'
     and cp.topannul is null
        --and tfac = 1
     and dev = (select max(dev)
                  from edmgalatee.cprofac
                 where centre = cp.centre
                   and client = cp.client
                   and ordre = cp.ordre
                   and facture = cp.facture)
        --and cp.centre = '006'
        --and cp.client = '0201109'
        --and sp.nis_rad = 200924586
        --and cp.compteur = 'A0094915112'
        --order by f_fact desc
     and not exists (select 0
            from galatee_readings
           where centre = cp.centre
             and client = cp.client
             and ordre = cp.ordre
             and compteur = cp.compteur);

insert into galatee_readings
  select cp.centre, cp.client, cp.ordre, sp.nis_rad, sp.sec_nis,
         sp.cod_unicom_serv, sp.cod_cli, sp.nif, cp.point, cp.compteur,
         case
           when substr(trim(cp.compteur), 1, 1) in ('R', 'D') then
            'A' || substr(trim(cp.compteur), 2)
           else
            trim(cp.compteur)
         end num_apa, cp.devpre, nindex lect, tfac, cp.coeflect,
         decode(ca.compteur, null, 'OLD', 'CURR') num_apa_curr, ca.cadcompt,
         facture, cp.conso csmo,
         decode(cp.point, 2, nindex, cp.nindex - cp.aindex) dif_lect
    from edmgalatee.cprofac cp, int_supply sp, edmgalatee.canalisation ca
   where cp.centre = sp.centre
     and cp.client = sp.client
     and cp.ordre = sp.ordre
     and cp.centre = ca.centre
     and cp.client = ca.ag
     and cp.compteur = ca.compteur
     and cp.topannul is null
     and sp.nis_rad is not null
        --and tfac = 1
     and dev = (select max(dev)
                  from edmgalatee.cprofac
                 where centre = cp.centre
                   and client = cp.client
                   and ordre = cp.ordre
                   and facture = cp.facture)
     and not exists (select 0
            from galatee_readings
           where centre = cp.centre
             and client = cp.client
             --and ordre = cp.ordre
             and compteur = cp.compteur)        
  --and cp.centre = '006'
  --and cp.client = '0201109'
  --and sp.nis_rad = 200924586
  --and cp.compteur = 'A0094915112'
  --order by cp.devpre desc
  ;

insert into galatee_readings
select sp.centre, sp.client, sp.ordre, sp.nis_rad, sp.sec_nis,
       sp.cod_unicom_serv, sp.cod_cli, sp.nif, ca.point, ca.compteur,
       case
         when substr(trim(ca.compteur), 1, 1) in ('R', 'D') then
          'A' || substr(trim(ca.compteur), 2)
         else
          trim(ca.compteur)
       end num_apa, ca.datepose, 0 lect, 1 tfac, ca.coeflect,
       decode(ca.compteur, null, 'OLD', 'CURR') num_apa_curr, ca.cadcompt, 0,
       0 csmo, 0 dif_lect
  from int_supply sp, edmgalatee.canalisation ca
 where sp.centre = ca.centre
   and sp.client = ca.ag
   and sp.nis_rad is not null
   and sp.est_sum = 'EC012'
   and trim(ca.compteur) is not null
   and ca.datepose is not null
   and not exists (select 0
          from galatee_readings e
         where e.centre = sp.centre
           and e.client = sp.client
           --and e.ordre = sp.ordre
           and e.compteur = ca.compteur)
      --and cp.centre = '006'
   --and sp.client = '1014137'
      --and sp.nis_rad = 200924586
   --and ca.compteur = 'A0000372194'
--order by cp.devpre desc
;
