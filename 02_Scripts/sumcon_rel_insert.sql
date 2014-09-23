insert into sumcon_rel@cmstst
  select distinct 'CONV_EDM', trunc(sysdate), 'CONV_EDM', ap.nis_rad, 1,
                  tr.num_transf, tr.co_marca, 0,
                  to_date(20010101, 'yyyymmdd'),
                  to_date(29991231, 'yyyymmdd'), 0
    from edmcamp.cadastramento_new ca, apmedida_ap ap,
         transformadores@cmstst tr
   where lower(boad_designacao) like '%xai%'
     and trim('XX-' || substr(bopt_nopt, instr(bopt_nopt, 'P')) || '-' ||
         substr(bopt_nopt, 1, instr(bopt_nopt, '-') - 1)) = tr.num_transf
     and tr.co_marca = 'ZT009'
     and ((ca.bocl_nocontador = ap.num_apa) or
          (tip_apa = 'TA100' and
          lpad(ca.bocl_nocontador, 11, 0) = ap.num_apa))
     and nis_rad not in
         (select nis_rad from sumcon_rel@cmstst where nis_rad = ap.nis_rad);
         

select ca.bopt_nopt, ca.bopt_designacao, num_apa, nis_rad, 'XX-' || substr(bopt_nopt, instr(bopt_nopt, 'P')) || '-' ||
         substr(bopt_nopt, 1, instr(bopt_nopt, '-') - 1) oms_num_transf
  from edmcamp.cadastramento_new ca, apmedida_ap ap
 where lower(boad_designacao) like '%xai%'
   and ((ca.bocl_nocontador = ap.num_apa) or
        (tip_apa = 'TA100' and lpad(ca.bocl_nocontador, 11, 0) = ap.num_apa))
   and nis_rad in (select nis_rad
                     from edmcamp.cadastramento_new ca, apmedida_ap ap
                    where lower(boad_designacao) like '%xai%'
                      and ((ca.bocl_nocontador = ap.num_apa) or
                           (tip_apa = 'TA100' and
                           lpad(ca.bocl_nocontador, 11, 0) = ap.num_apa))
                   --and tip_apa = 'TA100'
                   minus
                   select nis_rad
                     from sumcon_rel@cmstst);
                     
insert into sumcon_rel@cmstst
select distinct 'CONV_EDM', trunc(sysdate), 'CONV_EDM', ap.nis_rad, 1,
                  tr.num_transf, tr.co_marca, 0,
                  to_date(20010101, 'yyyymmdd'),
                  to_date(29991231, 'yyyymmdd'), 0
    from edmcamp.cadastramento_new ca, apmedida_ap ap,
         transformadores@cmstst tr, (select 'XX-146R - -146R' old_name, 'XX-PTP146R ' new_name from dual union
select 'XX-PT-107R' old_name, 'XX-PTP-107' new_name from dual union
select 'XX-PT-110R' old_name, 'XX-PTP-110' new_name from dual union
select 'XX-PT-111R' old_name, 'XX-PT-111R' new_name from dual union
select 'XX-PT-112R' old_name, 'XX-PT-112R' new_name from dual union
select 'XX-PT-113R' old_name, 'XX-PTP-113' new_name from dual union
select 'XX-PT-114R' old_name, 'XX-PT-114R' new_name from dual union
select 'XX-PT-119R' old_name, 'XX-PTP-119' new_name from dual union
select 'XX-PT-125R' old_name, 'XX-PT-125R' new_name from dual union
select 'XX-PT-126R' old_name, 'XX-PT-126R' new_name from dual union
select 'XX-PT-133R' old_name, 'XX-PTP-133' new_name from dual union
select 'XX-PT-134R' old_name, 'XX-PTP-134' new_name from dual union
select 'XX-PT-135R' old_name, 'XX-PTP-135' new_name from dual union
select 'XX-PT-137R' old_name, 'XX-PT-137R' new_name from dual union
select 'XX-PT-138R' old_name, 'XX-PT-138R' new_name from dual union
select 'XX-PT-145R' old_name, 'XX-PTP-145' new_name from dual union
select 'XX-PT-167R' old_name, 'XX-PT-167R' new_name from dual union
select 'XX-PT-171R' old_name, 'XX-PT-171R' new_name from dual union
select 'XX-PT-173R' old_name, 'XX-PT-173R' new_name from dual union
select 'XX-PT-178R' old_name, 'XX-PT-178R' new_name from dual union
select 'XX-PT-180R' old_name, 'XX-PTP-180' new_name from dual union
select 'XX-PT-189R' old_name, 'XX-PT-189R' new_name from dual union
select 'XX-PT-197R' old_name, 'XX-PT-197R' new_name from dual union
select 'XX-PT-21' old_name, 'XX-PT-21R' new_name from dual union
select 'XX-PT-211R' old_name, 'XX-PT-211R' new_name from dual union
select 'XX-PT-212R' old_name, 'XX-PT-212R' new_name from dual union
select 'XX-PT-218R' old_name, 'XX-PT-218R' new_name from dual union
select 'XX-PT-224' old_name, 'XX-PTP-224' new_name from dual union
select 'XX-PT-226' old_name, 'XX-PTP-226' new_name from dual union
select 'XX-PT-228' old_name, 'XX-PTP-228' new_name from dual union
select 'XX-PT-231' old_name, 'XX-PT-231R' new_name from dual union
select 'XX-PT-234' old_name, 'XX-PTP-234R' new_name from dual union
select 'XX-PT-236' old_name, 'XX-PT-236' new_name from dual union
select 'XX-PT-238' old_name, 'XX-PT-238' new_name from dual union
select 'XX-PT-243' old_name, 'XX-PT-243' new_name from dual union
select 'XX-PT-244' old_name, 'XX-PT-244' new_name from dual union
select 'XX-PT-247' old_name, 'XX-PT-247' new_name from dual union
select 'XX-PT-248' old_name, 'XX-PT-248' new_name from dual union
select 'XX-PT-249' old_name, 'XX-PT-249' new_name from dual union
select 'XX-PT-258' old_name, 'XX-PT-258' new_name from dual union
select 'XX-PT-260' old_name, 'XX-PT-260' new_name from dual union
select 'XX-PT-267' old_name, 'XX-PT-267' new_name from dual union
select 'XX-PT-268' old_name, 'XX-PT-268' new_name from dual union
select 'XX-PT-272' old_name, 'XX-PT-272' new_name from dual union
select 'XX-PT-285' old_name, 'XX-PT-285' new_name from dual union
select 'XX-PT-37R' old_name, 'XX-PT-37R' new_name from dual union
select 'XX-PT-38R' old_name, 'XX-PT-38R' new_name from dual union
select 'XX-PT-39R' old_name, 'XX-PT-39R' new_name from dual union
select 'XX-PT-41R' old_name, 'XX-PT-41R' new_name from dual union
select 'XX-PT-42R' old_name, 'XX-PT-42R' new_name from dual union
select 'XX-PT-43R' old_name, 'XX-PT-43R' new_name from dual union
select 'XX-PT-44R' old_name, 'XX-PT-44R' new_name from dual union
select 'XX-PT-46R' old_name, 'XX-PT-46R' new_name from dual union
select 'XX-PT-47R' old_name, 'XX-PT-47R' new_name from dual union
select 'XX-PT-48R' old_name, 'XX-PT-48R' new_name from dual union
select 'XX-PT-49R' old_name, 'XX-PT-49R' new_name from dual union
select 'XX-PT-56R' old_name, 'XX-PT-56R' new_name from dual union
select 'XX-PT-57R' old_name, 'XX-PT-57R' new_name from dual union
select 'XX-PT-58R' old_name, 'XX-PT-58R' new_name from dual union
select 'XX-PT-60R' old_name, 'XX-PT-60R' new_name from dual union
select 'XX-PT-61R' old_name, 'XX-PT-61R' new_name from dual union
select 'XX-PT-62R' old_name, 'XX-PT-62R' new_name from dual union
select 'XX-PT-63R' old_name, 'XX-PT-63R' new_name from dual union
select 'XX-PT-64R' old_name, 'XX-PT-64R' new_name from dual union
select 'XX-PT-65R' old_name, 'XX-PT-65R' new_name from dual union
select 'XX-PT-66R' old_name, 'XX-PT-66R' new_name from dual union
select 'XX-PT-67R' old_name, 'XX-PT-67R' new_name from dual union
select 'XX-PT-68R' old_name, 'XX-PT-68R' new_name from dual union
select 'XX-PT-69R' old_name, 'XX-PT-69R' new_name from dual union
select 'XX-PT-70R' old_name, 'XX-PT-70R' new_name from dual union
select 'XX-PT-71R' old_name, 'XX-PT-71R' new_name from dual union
select 'XX-PT-72R' old_name, 'XX-PT-72R' new_name from dual union
select 'XX-PT-73R' old_name, 'XX-PT-73R' new_name from dual union
select 'XX-PT-77R' old_name, 'XX-PT-77R' new_name from dual union
select 'XX-PT-78R' old_name, 'XX-PT-78R' new_name from dual union
select 'XX-PT-80R' old_name, 'XX-PT-80R' new_name from dual union
select 'XX-PT-81R' old_name, 'XX-PT-81R' new_name from dual union
select 'XX-PT-82R' old_name, 'XX-PT-82R' new_name from dual union
select 'XX-PT-83R' old_name, 'XX-PT-83R' new_name from dual union
select 'XX-PT-84R' old_name, 'XX-PT-84R' new_name from dual union
select 'XX-PT-85R' old_name, 'XX-PT-85R' new_name from dual union
select 'XX-PT-86R' old_name, 'XX-PT-86R' new_name from dual union
select 'XX-PT-87R' old_name, 'XX-PT-87R' new_name from dual union
select 'XX-PT-88R' old_name, 'XX-PT-88R' new_name from dual union
select 'XX-PT-89R' old_name, 'XX-PT-89R' new_name from dual union
select 'XX-PT-94R' old_name, 'XX-PTP-94R' new_name from dual union
select 'XX-PT-95R' old_name, 'XX-PT-95R' new_name from dual union
select 'XX-PTP-100R' old_name, 'XX-PTP-100R' new_name from dual union
select 'XX-PTP-115R' old_name, 'XX-PTP-115R' new_name from dual union
select 'XX-PTP-120R' old_name, 'XX-PTP-120R' new_name from dual union
select 'XX-PTP-13R' old_name, 'XX-PTP-13R' new_name from dual union
select 'XX-PTP-140R' old_name, 'XX-PTP-140R' new_name from dual union
select 'XX-PTP-148R' old_name, 'XX-PTP-148R' new_name from dual union
select 'XX-PTP-150R' old_name, 'XX-PTP-150R' new_name from dual union
select 'XX-PTP-168R' old_name, 'XX-PTP-168R' new_name from dual union
select 'XX-PTP-200R' old_name, 'XX-PTP-200R' new_name from dual union
select 'XX-PTP-204R' old_name, 'XX-PTP-204R' new_name from dual union
select 'XX-PTP-230R' old_name, 'XX-PTP-230R' new_name from dual union
select 'XX-PTP-250' old_name, 'XX-PTP-250' new_name from dual union
select 'XX-PTP-36R' old_name, 'XX-PTP-36R' new_name from dual union
select 'XX-PTP-40R' old_name, 'XX-PTP-40R' new_name from dual union
select 'XX-PTP-75R' old_name, 'XX-PTP-75R' new_name from dual union
select 'XX-PTP-76R' old_name, 'XX-PTP-76R' new_name from dual union
select 'XX-PTP-96R' old_name, 'XX-PTP-96R' new_name from dual union
select 'XX-PTP-97R' old_name, 'XX-PTP-97R' new_name from dual union
select 'XX-PTP-110'   old_name,                       'XX-PTP-110R' new_name from dual union
select 'XX-PTP-100R'  old_name,                     'XX-PTP-100' new_name from dual union
select 'XX-PTP-115R' old_name,                      'XX-PT-115R' new_name from dual union
select 'XX-PTP-13R' old_name,                        'XX-PT-13R' new_name from dual union
select 'XX-PTP-140R'  old_name,                     'XX-PT-140R' new_name from dual union
select 'XX-PTP-230R' old_name,                      'XX-PT-230R' new_name from dual union
select 'XX-PTP-234R' old_name,                      'XX-PT-234R' new_name from dual union
select 'XX-PTP-250' old_name,                         'XX-PT-250R' new_name from dual union
select 'XX-PTP-96R' old_name,                        'XX-PT-96R' new_name from dual union
select 'XX-PTP146R' old_name,                        'XX-PTP-146R'  new_name from dual union
select 'XX-PT-234' old_name,                      'XX-PT-234R' new_name from dual union
select 'XX-PT-110R' old_name,                      'XX-PTP-110R' new_name from dual union
select 'XX-146R - -146R' old_name,                      'XX-PTP-146' new_name from dual) aa
   where lower(boad_designacao) like '%xai%'
     and aa.new_name = tr.num_transf
     and tr.co_marca = 'ZT009'
     and ((ca.bocl_nocontador = ap.num_apa) or
          (tip_apa = 'TA100' and
          lpad(ca.bocl_nocontador, 11, 0) = ap.num_apa))
     and nis_rad not in
         (select nis_rad from sumcon_rel@cmstst where nis_rad = ap.nis_rad)
     and aa.old_name = trim('XX-' || substr(bopt_nopt, instr(bopt_nopt, 'P')) || '-' ||
         substr(bopt_nopt, 1, instr(bopt_nopt, '-') - 1));
