alter session set nls_date_format = 'yyyymmdd';
--Prebilling

select s.cod_unicom||' - '||u.nom_unicom "COmmercial Office", s.cod_tar||' - '||m.desc_tar "Customer Tariff", 
count(h.nis_RAd||h.sec_nis) "Service count", sum(h.csmo_fact) "Total Consumption", sum(h.imp_fact) "Pre-Billing Amount" 
from hfacturacion h, sumcon s, mtarifas m, unicom u 
where h.usuario not in ( 'CONV_EDM', 'TML' )
and h.nis_rad = s.nis_rad and h.sec_nis = s.sec_nis 
and s.cod_tar = m.cod_tar
and s.cod_unicom = u.cod_unicom
group by  s.cod_unicom||' - '||u.nom_unicom , s.cod_tar||' - '||m.desc_tar ;

--Collections

select to_char(f_pago, 'dd/mm/yyyy') "Payment date", p.cod_sucursal||' - '||s.nom_sucursal "Collection Agency",  
get_desc(1, 'T', p.tiprec) "Debt Type", get_desc(1, 'T', p.sie_forma_pago) "Payment Method", sum(imp_pago) "Amount"
from sucursales s, pagos p
where p.cod_sucursal = s.cod_sucursal
group by to_char(f_pago, 'dd/mm/yyyy'), p.cod_sucursal||' - '||s.nom_sucursal,  get_desc(1, 'T', p.tiprec), get_desc(1, 'T', p.sie_forma_pago);

--connections
select cod_unicom||'-'||nom_unicom "Commercial Office", count(*) "Count", to_char(e.f_sol, 'dd/mm/yyyy') "Request Date" , get_desc(1, 'T', e.tip_solic) "Request type", get_desc(1, 'E', e.estado) "Current Status"
from expedientes e, unicom u
where e.cod_unicom_compet = u.cod_unicom
and e.f_sol >= '20140801'
group by  cod_unicom||'-'||nom_unicom, to_char(e.f_sol, 'dd/mm/yyyy') , get_desc(1, 'T', e.tip_solic), get_desc(1, 'E', e.estado) ;


--contracts
select count(*),   u.cod_unicom||'-'||u.nom_unicom "Commercial Office", s.cod_tar||' - '||m.desc_tar "Customer Tariff"
from sumcon s, unicom u, mtarifas m
where s.nis_rad like '2%' and to_char(s.f_alta,'yyyymmdd') >= '20140801' and s.est_sum in ('EC014', 'EC012')
and s.cod_unicom = u.cod_unicom
and s.cod_tar = m.cod_tar
group by  u.cod_unicom||'-'||u.nom_unicom, s.cod_tar||' - '||m.desc_tar;

--debt analysis
SELECT NOM_unicom OFFICE,
SUM(DEBT_BEFORE) DEBT_BEFORE,SUM(PERIOD_DEBT)PERIOD_DEBT,SUM(PAID_AMOUNT)COLLECTION,(SUM(DEBT_BEFORE)+SUM(PERIOD_DEBT)-SUM(PAID_AMOUNT))BALANCE FROM 
(SELECT  U.NOM_UNICOM,  
        SUM(r.IMP_TOT_REC-r.IMP_CTA)AS DEBT_BEFORE ,0 PERIOD_DEBT,0 PAID_AMOUNT
 FROM RECIBOS r ,UNICOM U
 WHERE r.EST_ACT IN ('ER020','ER030','ER040','ER400','ER125','ER130','ER160','ER210','ER270','ER310','ER400','ER500','ER200')
 AND IMP_TOT_REC<>IMP_CTA 
 AND R.COD_UNICOM=U.COD_UNICOM
 and r.f_fact<'20140901'
GROUP BY U.NOM_UNICOM
UNION
SELECT  U.NOM_UNICOM,  0 DEBT_BEFORE,
        SUM(r.IMP_TOT_REC-r.IMP_CTA)AS PERIOD_DEBT,0 PAID_AMOUNT
 FROM RECIBOS r ,UNICOM U
 WHERE r.EST_ACT IN ('ER020','ER030','ER040','ER400','ER125','ER130','ER160','ER210','ER270','ER310','ER400','ER500','ER200')
 AND IMP_TOT_REC<>IMP_CTA 
 AND R.COD_UNICOM=U.COD_UNICOM
 and r.f_fact>='20140801'
  and r.f_fact<='20140831'
GROUP BY U.NOM_UNICOM
UNION 
SELECT  u.nom_unicom COD_UNICOM, 0 DEBT_BEFORE ,0 PERIOD_DEBT,
sum(DECODE(CO_OPERACION,'OC300',p.imp_pago,imp_pago*-1))PAID_AMOUNT
FROM sie_pagos p,sie_recibo_operacion r,grupos_rel g,unicom u
WHERE f_pago>='20140801' 
AND f_pago<='20140831'
and u.cod_unicom=p.cod_sucursal
and p.est_pago_ant=r.est_ANT
and p.est_pago_act=r.est_act
and g.cod_grupo=r.TIPO 
and g.codigo=p.tip_rec  
GROUP BY  u.nom_unicom
) GROUP BY NOM_UNICOM;
