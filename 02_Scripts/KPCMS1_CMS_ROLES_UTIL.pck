create or replace package CMS_ROLES_UTIL as

  PROCEDURE Get_Parametro(ls_param IN VARCHAR2, pc_valor1 IN OUT VARCHAR2, pc_valor2 IN OUT VARCHAR2);
  FUNCTION Get_Role RETURN number;
  PROCEDURE Get_Profile(ps_user IN VARCHAR2, ps_key OUT VARCHAR2, ps_user_permiso OUT VARCHAR2);
  function ascii_stg(ps_input in VARCHAR2) RETURN VARCHAR2;
  function sum_stg(ps_input in VARCHAR2) RETURN  number;
  PROCEDURE Get_Profile_key(ps_user IN VARCHAR2, ps_key OUT VARCHAR2, ps_user_permiso OUT VARCHAR2, ps_profile IN VARCHAR2);
end CMS_ROLES_UTIL; 
/
create or replace package body CMS_ROLES_UTIL is
-- *******************************************************************
  PROCEDURE Get_Parametro(ls_param IN VARCHAR2, pc_valor1 IN OUT VARCHAR2, pc_valor2 IN OUT VARCHAR2)
   IS
   BEGIN

     SELECT VALOR1, VALOR2
     INTO pc_valor1, pc_valor2
     FROM PARAMETROS
     WHERE PARAMETRO = ls_param
     AND F_VAL_PARAM <= SYSDATE
     AND F_ANUL_PARAM > SYSDATE;
  
  END ;
-- *******************************************************************
  FUNCTION Get_Role RETURN number AS
    v_role number := 0;
  BEGIN
      select cod_el_papel
        into v_role
        from usuarios
       where nom_usr = USER;
    return v_role;
  END Get_Role;
      
-- *******************************************************************
  PROCEDURE Get_Profile(ps_user IN VARCHAR2, ps_key OUT VARCHAR2, ps_user_permiso OUT VARCHAR2)
    AS
     ls_perfil       varchar2(32); /*BOO 20131109 KPCMS-357 changed from 16*/ 
    li_user_role    number;
    ll_cod_unicom   number;
    lf_trans_date   varchar2(8);
    ls_trans_time   varchar2(4);
  begin

    SELECT up.nom_perfil, u.cod_el_papel, LPAD(to_char(u.cod_permiso), 8, '0'),
           u.cod_unicom, to_char(u.f_actual, 'yyyymmdd'),
           to_char(u.f_actual, 'hh24mi')
      INTO ls_perfil, li_user_role, ps_user_permiso, ll_cod_unicom,
           lf_trans_date, ls_trans_time
      FROM usuarios u, usuario_perfil up
     WHERE u.nom_usr = ps_user
       AND up.nom_usr = u.nom_usr;
       --AND ul.nom_usr = u.nom_usr;
       
    ps_key := ascii_stg(ps_user) || ls_trans_time ||
              LPAD(li_user_role, 2, '0') || lf_trans_date ||
              ascii_stg(ls_perfil) || '000' || ll_cod_unicom;
 end Get_Profile;

-- *******************************************************************
  PROCEDURE Get_Profile_key(ps_user IN VARCHAR2, ps_key OUT VARCHAR2, ps_user_permiso OUT VARCHAR2, ps_profile IN VARCHAR2)
  AS
    ls_perfil       varchar2(32); /*BOO 20131109 KPCMS-357 changed from 16*/ 
    li_user_role    number;
    ll_cod_unicom   number;
    lf_trans_date   varchar2(8);
    ls_trans_time   varchar2(4);
  begin

    SELECT ps_profile, u.cod_el_papel, LPAD(to_char(u.cod_permiso), 8, '0'),
           u.cod_unicom, to_char(u.f_actual, 'yyyymmdd'),
           to_char(u.f_actual, 'hh24mi')
      INTO ls_perfil, li_user_role, ps_user_permiso, ll_cod_unicom,
           lf_trans_date, ls_trans_time
      FROM usuarios u
     WHERE u.nom_usr = ps_user
       AND u.nom_usr = u.nom_usr;
       
    ps_key := ascii_stg(ps_user) || ls_trans_time ||
              LPAD(li_user_role, 2, '0') || lf_trans_date ||
              ascii_stg(ls_perfil) || '000' || ll_cod_unicom;
 end Get_Profile_key;
--**************** **************************************************
  function ascii_stg(ps_input in VARCHAR2) RETURN VARCHAR2 IS
    i         number;
    ls_output VARCHAR2(200) := NULL;
  begin

    FOR i in 1 .. LENGTH(ps_input) LOOP
      ls_output := ls_output || ascii(upper(substr(ps_input, i, 1)));
    END LOOP;

    return ls_output;

  END ascii_stg;

-- ******************SUM STRING *************************************************
function sum_stg(ps_input in VARCHAR2) RETURN  number IS
  i integer;
  ls_sum number := 0;
begin
   FOR i in 1 .. LENGTH(ps_input) LOOP
      ls_sum := ls_sum +  ascii(substr(ps_input, i, 1));
    END LOOP;
    return ls_sum;
end sum_stg;
-- ******************END PACKAGE BODY *************************************************

end CMS_ROLES_UTIL;
/
