create or replace procedure conversion_int_supply_all(gls_system_id in varchar2) is
  /**
  * <b>Procedure</b></br>
  * Procedure to load the table INT_SUPPLY with the data from Galatee, Access and Eclipse. 
  * INT_SUPPLY is the main staging table for creation of premise, customer, account, supply point 
  * and service data for CMS. It is in this table where the data is 
  * transformed and CMS equivalence codes are added to the data. 
  *
  * @param gls_system_id This is varchar2 in. The valid values for this parameter are
  * <ul>
  *  <li> '01' - For Galatee</li>
  *  <li> '02' - For Access</li>
  *  <li> '03' - For Eclipse</li>
  * </ul>
  * It is required to specify the system one would like to convert for table INT_SUPPLY
  * @author tmlangeni@eservicios.indracompany.com
  */
  lcur_data sys_refcursor;
  type lcur_data_rec is record(
    system_id varchar2(2),
    centre    varchar2(10),
    client    varchar2(20),
    ordre     varchar2(2),
    fullname  varchar2(300),
    title     varchar2(30),
    firstname varchar2(120),
    surname   varchar2(120),
    tarif     varchar2(60),
    address   varchar2(4000),
    nuit      varchar2(30),
    tel_one   varchar2(30),
    tel_two   varchar2(30),
    email     varchar2(300),
    pot       float,
    f_baja    date,
    f_alta    date,
    est_serv  varchar2(5));

  lcur_data_rec$ lcur_data_rec;

  function get_galatee_record return sys_refcursor is
    lcur_galatee sys_refcursor;
  begin
    open lcur_galatee for
      select '01' system_id, a.centre, a.client, c.ordre, c.nomabon fullname,
             denabon title, ' ' firstname, nomabon surname, a.tarif,
             nvl(trim('|' || nomrue || ' ' || numrue || ' ' || comprue || ' ' ||
                       etage), ' ') address, nuit, g.telephone tel_one,
             ' ' tel_two, c.email, a.puissance pot, a.dres f_baja,
             a.dabon f_alta,
             case
               when trim(dres) is null then
                'EC012'
               else
                'EC021'
             end est_serv
        from edmgalatee.client c, edmgalatee.abon a, edmgalatee.ag g
       where c.centre = a.centre
         and c.centre = g.centre
         and c.client = a.client
         and c.client = g.ag
         and not exists (select 0
                from int_supply
               where centre = c.centre
                 and client = c.client
                 and ordre = c.ordre);
  
    return lcur_galatee;
  end get_galatee_record;

  function get_access_record return sys_refcursor is
    lcur_access sys_refcursor;
  begin
    open lcur_access for
      select '02' system_id, to_char(d.zona) centre,
             to_char(d.no_da_instalacao) client, '0' ordre,
             trim(apelido || ' ' || nome) fullname, ' ' title,
             apelido firstname, nome surname, to_char(d.categoria) tarif,
             '|' || endereco address, nuit, ' ' tel_one, ' ' tel_two,
             d.email, d.potencia pot, t.datanovocontador f_baja,
             t.data_de_instalacao f_alta,
             decode(d.activo, 1, 'EC012', 'EC021') est_serv
        from edmaccess.consumidores d, edmaccess.contador t
       where d.zona = t.zona
         and d.no_da_instalacao = t.no_da_instalacao
         and not exists
       (select 0
                from int_supply
               where centre = to_char(d.zona)
                 and client = to_char(d.no_da_instalacao));
  
    return lcur_access;
  end get_access_record;

  function get_eclipse_record return sys_refcursor is
    lcur_eclipse sys_refcursor;
  begin
    open lcur_eclipse for
      select '03' system_id, '999' centre, msno client, '00' ordre,
             trim(e.legal_entity_name || ' ' || e.first_names) fullname,
             ' ' title, first_names firstname, e.legal_entity_name surname,
             e.meter_trf_code tarif,
             trim('|' || e.loc_addr1 || ' ' || e.loc_addr2 || ' ' ||
                   e.loc_addr3) address, ' ' nuit, e.tel tel_one,
             ' ' tel_two, e.email, 0 pot,
             to_date(29991231, 'yyyymmdd') f_baja, e.inst_date f_alta,
             'EC012' est_serv
        from edmeclipse.customer_data e
       where status = 'Active'
         and regexp_instr(msno, '[[:alpha:]]') = 0
         and not exists
       (select 0 from int_supply where client = e.msno);
  
    return lcur_eclipse;
  end get_eclipse_record;
  
  

begin
  if gls_system_id = '01' then
    lcur_data := get_galatee_record;
  elsif gls_system_id = '02' then
    lcur_data := get_access_record;
  elsif gls_system_id = '03' then
    lcur_data := get_eclipse_record;
  else
    raise_application_error(-20008,
                            'You have specified invalid parameter for system to convert.' ||
                             chr(10) ||
                             'Valid values are ''01'',''02'' and ''03''');
  end if;

  loop
    begin
      fetch lcur_data
        into lcur_data_rec$;
      exit when lcur_data%notfound;
      
      
    exception
      when others then
        dbms_output.put_line(sqlerrm || '  --> ' || lcur_data_rec$.client);
    end;
  end loop;

end conversion_int_supply_all;
/
