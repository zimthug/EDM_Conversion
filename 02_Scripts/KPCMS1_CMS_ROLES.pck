create or replace package CMS_ROLES AUTHID CURRENT_USER as

  -- Types defined in this package
  Type data_t is varray(10) of INTEGER;
  TYPE array_t IS TABLE OF data_t;

  -- Initiliaze the structures.
  F array_t := new array_t(new data_t(0, 1, 2, 3, 4, 5, 6, 7, 8, 9),
                           new data_t(1, 5, 7, 6, 2, 8, 3, 0, 9, 4),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                           new data_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0));

  Op array_t := new array_t(new data_t(0, 1, 2, 3, 4, 5, 6, 7, 8, 9),
                            new data_t(1, 2, 3, 4, 0, 6, 7, 8, 9, 5),
                            new data_t(2, 3, 4, 0, 1, 7, 8, 9, 5, 6),
                            new data_t(3, 4, 0, 1, 2, 8, 9, 5, 6, 7),
                            new data_t(4, 0, 1, 2, 3, 9, 5, 6, 7, 8),
                            new data_t(5, 9, 8, 7, 6, 0, 4, 3, 2, 1),
                            new data_t(6, 5, 9, 8, 7, 1, 0, 4, 3, 2),
                            new data_t(7, 6, 5, 9, 8, 2, 1, 0, 4, 3),
                            new data_t(8, 7, 6, 5, 9, 3, 2, 1, 0, 4),
                            new data_t(9, 8, 7, 6, 5, 4, 3, 2, 1, 0));

  Inv data_t := new data_t(0, 4, 3, 2, 1, 5, 6, 7, 8, 9);

  FUNCTION Set_Role(P_SI_ID IN PLS_INTEGER, P_IP_ADD IN VARCHAR2,
                    pi_origin IN PLS_INTEGER) RETURN PLS_INTEGER;
   FUNCTION hash_SI  RETURN PLS_INTEGER;
  function Create_Hash  (P_HASH_ID IN PLS_INTEGER)  return PLS_INTEGER;
  function generate_hash(ps_input in VARCHAR2) RETURN VARCHAR2;
  function Get_Key (ps_user IN VARCHAR2) return VARCHAR2;
  function mask_stg(ps_input in VARCHAR2) RETURN VARCHAR2;
  function Get_ProfileKey (ps_user IN VARCHAR2,ps_profile IN VARCHAR2 ) return VARCHAR2;
end CMS_ROLES; 
/
create or replace package body CMS_ROLES is

  function Verify_Key(pi_origin IN PLS_INTEGER) RETURN PLS_INTEGER;
  FUNCTION Verify_SI(P_SI_ID IN PLS_INTEGER, P_SI_ID2 IN VARCHAR2,
                     pi_origin IN PLS_INTEGER) RETURN PLS_INTEGER;
  FUNCTION Verify_IP(P_IP IN VARCHAR2, pi_origin IN PLS_INTEGER)
    RETURN PLS_INTEGER;
  function generate_key(ps_input in VARCHAR2) RETURN VARCHAR2;
  FUNCTION reverse_stg(ps_input in VARCHAR2) RETURN VARCHAR2;
  FUNCTION ascii_stg(ps_input in VARCHAR2) RETURN VARCHAR2;
  function isdigit(a in VARCHAR) return boolean;
  function get_key_value(ps_user IN VARCHAR2, ps_key OUT VARCHAR2,
                         ps_user_permiso OUT VARCHAR2) RETURN PLS_INTEGER;
  PROCEDURE Get_Hash3(ps_key OUT VARCHAR2);
  function Get_key_profile_value(ps_user IN VARCHAR2, ps_key OUT VARCHAR2,
                                 ps_user_permiso OUT VARCHAR2,
                                 ps_profile IN VARCHAR2) return PLS_INTEGER;

  lc_error VARCHAR(500);

  -- *******************************************************************
  FUNCTION Set_Role(P_SI_ID IN PLS_INTEGER, P_IP_ADD IN VARCHAR2,
                    pi_origin IN PLS_INTEGER) RETURN PLS_INTEGER AS
    li_rtn PLS_INTEGER;
  BEGIN
    li_rtn := Verify_Key(pi_origin);
    if li_rtn = 0 THEN
      li_rtn := Verify_IP(P_IP_ADD, pi_origin);
      if li_rtn = 0 THEN
        li_rtn := Verify_SI(P_SI_ID, P_IP_ADD, pi_origin);
      END IF;
    END IF;
    if li_rtn != 0 THEN
      RAISE_APPLICATION_ERROR(-20000 - li_rtn, lc_error);
    end if;

    return li_rtn;
  END Set_Role;

  -- *******************************************************************
  FUNCTION Verify_SI(P_SI_ID IN PLS_INTEGER, P_SI_ID2 IN VARCHAR2,
                     pi_origin IN PLS_INTEGER) RETURN PLS_INTEGER AS
    v_cod_el_papel PLS_INTEGER;
    r_string       VARCHAR2(50);
    r_name         VARCHAR2(50);
    ll_hash3       number(9);
    still_have_employees EXCEPTION;
    pragma autonomous_transaction;
  BEGIN

    IF hash_SI() = P_SI_ID THEN
      if pi_origin in (0, 2) THEN
        ll_hash3 := Create_Hash(P_SI_ID);
        if ll_hash3 = 24 THEN
          return 24;
        END IF;
        if ll_hash3 <> TO_NUMBER(P_SI_ID2) THEN
          -- return 0;
          -- No hash yet
          dbms_output.put_line(r_string);
        end if;
      END IF;
      r_string := UTL_RAW.cast_to_varchar2(HEXTORAW('73457420526F6C45'));

      IF pi_origin in (0, 1) THEN
        BEGIN
           v_cod_el_papel := CMS_ROLES_UTIL.Get_Role();


        exception
          when others then
            lc_error := 'Failed to get the Role';
        END;

        CASE
          WHEN v_cod_el_papel = 1 THEN
            r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('456E445F75536552735F526F'));
            return 0; -- all user have default RO user profile
          WHEN v_cod_el_papel = 2 THEN
            r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('456E445F75536552735F5277'));
          ELSE
            r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('2020206E4F4E6520'));
        END CASE;
      ELSIF pi_origin in (2, 11) THEN
        /*  Changed for KPLC  BOO KPIMS -357 20130310 changed for KPLC */
        --r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('5365435F724F6C'));
        r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('755365525F4D67545F724F6C65'));
      ELSIF pi_origin = 3 THEN
        --r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('456E445F75536552735F4261546348')); -- BOO KPIMS -357 20130310 changed for KPLC
        r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('4261546348'));


      ELSE
        r_name := UTL_RAW.cast_to_varchar2(HEXTORAW('2020206E4F4E6520'));
      END IF;

      r_string := r_string || ' ' || r_name;
      --dbms_output.put_line(r_string);
      BEGIN
        EXECUTE IMMEDIATE r_string;
      EXCEPTION
        WHEN others THEN
          lc_error := ' EXECUTE IMMEDIATE' || sqlerrm;
          return 20;
      END;

      RETURN 0;
    ELSE
      lc_error := 'Hashed SI different. Operation halted';
      RETURN 21;
    END IF;
  END Verify_SI;
  -- *******************************************************************
  FUNCTION Verify_IP(P_IP IN VARCHAR2, pi_origin IN PLS_INTEGER)
    RETURN PLS_INTEGER AS

    s_audsid    VARCHAR2(50) := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
    p1_num_rec  VARCHAR2(4096) := '';
    num_all     VARCHAR2(255) := '';
    num         NUMBER := 0;
    step_len    PLS_INTEGER := 1;
    p1_number   PLS_INTEGER;
    p1_position PLS_INTEGER := 1;
    lc_valor1   VARCHAR2(50);
    lc_valor2   VARCHAR2(50);
    ls_param    VARCHAR2(50);
    pragma autonomous_transaction;
  BEGIN

    if pi_origin = 1 THEN
      -- OPENLINK
      ls_param := 'IP_ADD_OPLINK';
    elsif pi_origin in (11) THEN
      -- SECURITY
      ls_param := 'IP_ADD_SECURITY';
    elsif pi_origin = 3 THEN
      -- BATCH
      ls_param := 'IP_ADD_BATCH';
    elsif pi_origin = 4 THEN
      -- REP_OPENLINK
      ls_param := 'IP_ADD_REP_OPLINK';
    else
      return 0;
    end if;

    BEGIN
      CMS_ROLES_UTIL.Get_Parametro(ls_param, lc_valor1, lc_valor2);
    EXCEPTION
      WHEN others THEN
        lc_error := 'Verify_IP ::' || sqlerrm;
        return 10;
    END;

    if lc_valor1 != '1' THEN
      return 0;
    end if;

    if instr(lc_valor2, s_audsid, 1) = 0 THEN
      lc_error := 'IP address of application server not Authorised to Execute. Operation halted';
      return 11;
    END IF;

    for i in 1 .. LENGTH(s_audsid) loop
      if NOT isdigit(SUBSTR(s_audsid, i, 1)) THEN
        p1_number  := MOD(ascii(SUBSTR(s_audsid, i, 1)), 10);
        p1_num_rec := p1_num_rec || to_char(p1_number);
      else
        p1_num_rec := p1_num_rec || SUBSTR(s_audsid, i, 1);
      END IF;
    END LOOP;

    s_audsid   := p1_num_rec;
    p1_num_rec := '';

    LOOP
      p1_number   := TO_NUMBER(SUBSTR(s_audsid, p1_position, step_len));
      p1_number   := MOD(p1_number, 25);
      p1_number   := p1_number + 65;
      p1_num_rec  := p1_num_rec || CHR(p1_number);
      p1_position := p1_position + step_len;
      step_len    := step_len + 1;
      EXIT WHEN p1_position > LENGTH(s_audsid);
    END LOOP;

    FOR i IN 1 .. LENGTH(p1_num_rec) LOOP
      CASE SUBSTR(p1_num_rec, i, 1)
        WHEN 'A' THEN
          num_all := num_all || '1';
        WHEN 'B' THEN
          num_all := num_all || '2';
        WHEN 'C' THEN
          num_all := num_all || '3';
        WHEN 'D' THEN
          num_all := num_all || '4';
        WHEN 'E' THEN
          num_all := num_all || '5';
        WHEN 'F' THEN
          num_all := num_all || '6';
        WHEN 'G' THEN
          num_all := num_all || '7';
        WHEN 'H' THEN
          num_all := num_all || '8';
        WHEN 'I' THEN
          num_all := num_all || '9';
        WHEN 'J' THEN
          num_all := num_all || '1';
        WHEN 'K' THEN
          num_all := num_all || '2';
        WHEN 'L' THEN
          num_all := num_all || '3';
        WHEN 'M' THEN
          num_all := num_all || '4';
        WHEN 'N' THEN
          num_all := num_all || '5';
        WHEN 'O' THEN
          num_all := num_all || '6';
        WHEN 'P' THEN
          num_all := num_all || '7';
        WHEN 'Q' THEN
          num_all := num_all || '8';
        WHEN 'R' THEN
          num_all := num_all || '9';
        WHEN 'S' THEN
          num_all := num_all || '1';
        WHEN 'T' THEN
          num_all := num_all || '2';
        WHEN 'U' THEN
          num_all := num_all || '3';
        WHEN 'V' THEN
          num_all := num_all || '4';
        WHEN 'W' THEN
          num_all := num_all || '5';
        WHEN 'X' THEN
          num_all := num_all || '6';
        WHEN 'Y' THEN
          num_all := num_all || '7';
        WHEN 'Z' THEN
          num_all := num_all || '8';
      END CASE;
    END LOOP;

    num         := 0;
    p1_position := 1;

    LOOP
      num         := num + TO_NUMBER(SUBSTR(num_all, p1_position, 2));
      p1_position := p1_position + 2;
      EXIT WHEN p1_position > LENGTH(num_all);
    END LOOP;

    num := num + TO_NUMBER(num_all);
    FOR i IN 1 .. LENGTH(s_audsid) LOOP
      num := num + num * TO_NUMBER(SUBSTR(s_audsid, i, 1));
    END LOOP;

    dbms_output.put_line('IP Address is ' || num);
    IF to_char(num) = P_IP THEN
      return 0;
    ELSE
      lc_error := 'Hashed IP different. Operation halted';
      return 12;
    END IF;
  END;

  -- *******************************************************************
  function Get_Key(ps_user IN VARCHAR2) return VARCHAR2 is
    ls_user_permiso varchar2(16);
    ls_key          varchar2(200);
  BEGIN
    if Get_Key_value(ps_user, ls_key, ls_user_permiso) <> 0 THEN
      return ' ';
    END if;
    return ls_key;
  end Get_Key;

  -- *******************************************************************
  function Get_ProfileKey(ps_user IN VARCHAR2, ps_profile IN VARCHAR2)
    return VARCHAR2 is
    ls_user_permiso varchar2(16);
    ls_key          varchar2(200);
  BEGIN
    if Get_Key_profile_value(ps_user, ls_key, ls_user_permiso, ps_profile) <> 0 THEN
      return ' ';
    END if;
    return ls_key;
  end Get_ProfileKey;
  --*******************************************************************
  FUNCTION Schema_owner RETURN INTEGER is
    v_role number := 0;
  BEGIN
    SELECT COUNT(distinct AZ.OWNER)
      INTO v_role
      FROM ALL_TABLES AZ
     WHERE TABLE_NAME IN ('USUARIOS')
       AND AZ.OWNER = USER;
    return v_role;
  END Schema_owner;
  -- *******************************************************************
  function Verify_Key(pi_origin IN PLS_INTEGER) return PLS_INTEGER is
    ls_user_permiso varchar2(16);
    ls_key          varchar2(200);
  begin

    if Schema_owner = 1 or pi_origin in (2, 11, 22) THEN
      return 0; /* Key is ok */
    END IF;

    if Get_Key_value(USER, ls_key, ls_user_permiso) <> 0 THEN
      return 1;
    END if;

    dbms_output.put_line(ls_key || '::' || ls_user_permiso);

    if ls_key = ls_user_permiso THEN
      return 0; /* Key is ok */
    else
      lc_error := 'The profile Key is invalid';
      return 2; /* key not the same */
    end if;

  end Verify_Key;

  -- *******************************************************************
  function Get_key_value(ps_user IN VARCHAR2, ps_key OUT VARCHAR2,
                         ps_user_permiso OUT VARCHAR2) return PLS_INTEGER is
    ls_user_permiso varchar2(16);
    ls_key          varchar2(200);

  BEGIN
    BEGIN

      cms_roles_util.Get_Profile(ps_user, ls_key, ls_user_permiso);

    EXCEPTION
      WHEN others THEN
        lc_error        := 'Getting Profile key::' || sqlerrm;
        ps_key          := ' ';
        ps_user_permiso := ' ';
        return 1;
    END;

    ps_key          := generate_key(ls_key);
    ps_user_permiso := ls_user_permiso;

    return 0;
  end get_key_value;

  -- *******************************************************************
  function Get_key_profile_value(ps_user IN VARCHAR2, ps_key OUT VARCHAR2,
                                 ps_user_permiso OUT VARCHAR2,
                                 ps_profile IN VARCHAR2) return PLS_INTEGER is
    ls_user_permiso varchar2(16);
    ls_key          varchar2(200);

  BEGIN
    BEGIN

      cms_roles_util.Get_Profile_key(ps_user, ls_key, ls_user_permiso,
                                     ps_profile);

    EXCEPTION
      WHEN others THEN
        lc_error        := 'Getting Profile key::' || sqlerrm;
        ps_key          := ' ';
        ps_user_permiso := ' ';
        return 1;
    END;

    ps_key          := generate_key(ls_key);
    ps_user_permiso := ls_user_permiso;

    return 0;
  end Get_key_profile_value;

  -- *******************************************************************
  function Create_Hash(P_HASH_ID IN PLS_INTEGER) return PLS_INTEGER is
    ls_key        varchar2(4000);
    ls_fixed_hash varchar2(30) := 'thisisates#53783vjBNVNVNV';
    ls_hash1      varchar2(16) := to_char(p_hash_id);
    ls_hash2      varchar2(500);
  BEGIN
    BEGIN

      Get_Hash3(ls_key);

    EXCEPTION
      WHEN others THEN
        lc_error := 'Get_Hash3::' || sqlerrm;
        return 24;
    END;
    ls_hash2 := generate_hash(mask_stg(ls_hash1) || ls_fixed_hash ||
                              generate_hash(ls_key));

    return to_number(ls_hash2);
  end Create_Hash;

  -- *******************************************************************
  PROCEDURE Get_Hash3(ps_key OUT VARCHAR2) AS
    ls_key varchar(4000);
  begin

    for c1 in (select * from online_files) loop
      ls_key := ls_key || generate_hash(c1.file_name);
    end loop;

    ps_key := ls_key;
  end Get_Hash3;

  -- *******************************************************************
  function reverse_stg(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    i      number := 1;
    ls_out VARCHAR2(2000) := NULL;

  BEGIN

    FOR i IN REVERSE 1 .. LENGTH(ps_input) LOOP
      ls_out := ls_out || substr(ps_input, i, 1);
    END LOOP;

    return ls_out;

  END reverse_stg;

  -- *******************************************************************
  function ascii_stg(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    i         number;
    ls_output VARCHAR2(200) := NULL;
  begin

    FOR i in 1 .. LENGTH(ps_input) LOOP
      ls_output := ls_output || ascii(upper(substr(ps_input, i, 1)));
    END LOOP;

    return ls_output;

  END ascii_stg;

  -- *******************************************************************
  function mask_stg(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    i         number;
    ls_output VARCHAR2(200) := NULL;
  begin

    FOR i in 1 .. LENGTH(ps_input) LOOP
      ls_output := ls_output ||
                   CHR(mod(ascii(substr(ps_input, i, 1)), 52) + 65);
    END LOOP;

    return ls_output;

  END mask_stg;
  -- *******************************************************************
  function generate_hash(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    i             integer := 1;
    j             integer := 0;
    x             NUMBER(9) := 0;
    y             NUMBER(9) := 0;
    ll_sub        integer := 0;
    ll_value      NUMBER(9) := 0;
    a_stg_reverse varchar2(2000);
    ll_len        integer := 0;
  begin
    a_stg_reverse := reverse_stg(ps_input);
    ll_len        := length(ps_input);
    while i <= ll_len loop
      ll_sub := ll_sub + 1;
      x      := 0;
      y      := 0;
      for j in 1 .. ll_sub loop
        if i > ll_len THEN
          exit;
        end if;
        x := x + ascii(substr(a_stg_reverse, i, 1));
        y := y + ascii(substr(ps_input, i, 1));
        i := i + 1;
      end loop;
      if x != 0 THEN
        ll_value := ll_value + (y * x);
      end if;
    end loop;

    return to_char(ll_value);

  END generate_hash;

  -- *******************************************************************
  function generate_key(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    ls_in_string varchar2(200);
    a_stg        varchar2(200);
    i            integer := 0;
    j            integer := 0;
    x            integer := 0;
    y            integer := 0;
    li_check     integer := 1;
    c            varchar2(1);
  begin
    ls_in_string := ps_input;
    for i in 1 .. 8 loop
      a_stg := 'x' || reverse_stg(ls_in_string);
      for j in 2 .. LENGTH(a_stg) loop
        c := substr(a_stg, j, 1);
        if isdigit(c) THEN
          x := mod(j - 1, 8) + 1;
          y := to_number(c) + 1;
        else
          x := mod(j - 1, 8) + 1;
          y := mod(ascii(c), 10) + 1;
        END IF;
        li_check := Op(li_check) (F(x) (y) + 1) + 1;
      end loop;

      ls_in_string := ls_in_string || Inv(li_check);

    end loop;

    return(substr(ls_in_string, -8));

  END generate_key;
  -- *******************************************************************
  function isdigit(a in VARCHAR) return boolean IS

  begin
    if ASCII(a) NOT BETWEEN 48 AND 57 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END isdigit;
  -- *******************************************************************
  FUNCTION hash_SI RETURN PLS_INTEGER AS
    s_audsid    PLS_INTEGER := SYS_CONTEXT('USERENV', 'SESSIONID');
    p1_num_rec  VARCHAR2(4096) := '';
    num_all     VARCHAR2(255) := '';
    num         PLS_INTEGER := 0;
    step_len    PLS_INTEGER := 1;
    p1_number   PLS_INTEGER;
    p1_position PLS_INTEGER := 1;
  BEGIN

    LOOP
      p1_number   := TO_NUMBER(SUBSTR(TO_CHAR(s_audsid), p1_position,
                                      step_len));
      p1_number   := MOD(p1_number, 25);
      p1_number   := p1_number + 65;
      p1_num_rec  := p1_num_rec || CHR(p1_number);
      p1_position := p1_position + step_len;
      step_len    := step_len + 1;
      EXIT WHEN p1_position > LENGTH(s_audsid);
    END LOOP;

    --DBMS_OUTPUT.put_line(s_audsid);
    --DBMS_OUTPUT.put_line(p1_num_rec);

    FOR i IN 1 .. LENGTH(p1_num_rec) LOOP
      CASE SUBSTR(p1_num_rec, i, 1)
        WHEN 'A' THEN
          num_all := num_all || '1';
        WHEN 'B' THEN
          num_all := num_all || '2';
        WHEN 'C' THEN
          num_all := num_all || '3';
        WHEN 'D' THEN
          num_all := num_all || '4';
        WHEN 'E' THEN
          num_all := num_all || '5';
        WHEN 'F' THEN
          num_all := num_all || '6';
        WHEN 'G' THEN
          num_all := num_all || '7';
        WHEN 'H' THEN
          num_all := num_all || '8';
        WHEN 'I' THEN
          num_all := num_all || '9';
        WHEN 'J' THEN
          num_all := num_all || '1';
        WHEN 'K' THEN
          num_all := num_all || '2';
        WHEN 'L' THEN
          num_all := num_all || '3';
        WHEN 'M' THEN
          num_all := num_all || '4';
        WHEN 'N' THEN
          num_all := num_all || '5';
        WHEN 'O' THEN
          num_all := num_all || '6';
        WHEN 'P' THEN
          num_all := num_all || '7';
        WHEN 'Q' THEN
          num_all := num_all || '8';
        WHEN 'R' THEN
          num_all := num_all || '9';
        WHEN 'S' THEN
          num_all := num_all || '1';
        WHEN 'T' THEN
          num_all := num_all || '2';
        WHEN 'U' THEN
          num_all := num_all || '3';
        WHEN 'V' THEN
          num_all := num_all || '4';
        WHEN 'W' THEN
          num_all := num_all || '5';
        WHEN 'X' THEN
          num_all := num_all || '6';
        WHEN 'Y' THEN
          num_all := num_all || '7';
        WHEN 'Z' THEN
          num_all := num_all || '8';
      END CASE;
    END LOOP;

    num         := 0;
    p1_position := 1;

    LOOP
      num         := num + TO_NUMBER(SUBSTR(num_all, p1_position, 2));
      p1_position := p1_position + 2;
      EXIT WHEN p1_position > LENGTH(num_all);
    END LOOP;

    num := num + TO_NUMBER(num_all);

    FOR i IN 1 .. LENGTH(TO_CHAR(s_audsid)) LOOP
      num := num + num * TO_NUMBER(SUBSTR(TO_CHAR(s_audsid), i, 1));
      num := MOD(NUM, 214748364);
    END LOOP;

    DBMS_OUTPUT.put_line('hashed id = ' || num);
    return num;
  END hash_SI;
  -- ******************END PACKAGE BODY *************************************************
end CMS_ROLES;
/
