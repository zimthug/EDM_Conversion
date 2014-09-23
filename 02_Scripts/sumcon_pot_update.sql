update sumcon set pot = 6600 where pot in ( 6000, 7000, 5000);

update sumcon set pot = 3300 where pot in ( 3000, 4000);

update sumcon set pot = 2200 where pot in ( 2000);

update sumcon set pot = 19800 where pot in ( 21000);

update sumcon set pot = 13200 where pot in ( 14000);

select distinct pot from sumcon where cod_mask != 4096 and tip_suministro != 'SU900';
