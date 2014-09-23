CREATE OR REPLACE PACKAGE SGC.XML_API
AS
   PROCEDURE ADDEMPLOYEEBONUS (
      DATETIME       IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'yyyymmdd'),
      UNIQUENUMBER   IN VARCHAR2 DEFAULT NULL,
      P_NUIT         IN VARCHAR2 DEFAULT NULL,
      P_BI           IN VARCHAR2 DEFAULT NULL,
      P_EMPNUMBER    IN NUMBER DEFAULT NULL,
      P_EMPSTATUS    IN VARCHAR2 DEFAULT NULL,
      P_START_DATE   IN VARCHAR2 DEFAULT NULL,
      P_END_DATE     IN VARCHAR2 DEFAULT NULL);

   PROCEDURE DELETEEMPLOYEEBONUS (
      DATETIME       IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'yyyymmdd'),
      UNIQUENUMBER   IN VARCHAR2 DEFAULT NULL,
      P_NUIT         IN VARCHAR2 DEFAULT NULL,
      P_BI           IN VARCHAR2 DEFAULT NULL,
      P_EMPNUMBER    IN NUMBER DEFAULT NULL,
      P_FINDATE      IN VARCHAR2 DEFAULT NULL,
      P_EMPSTATUS    IN VARCHAR2 DEFAULT NULL);
END XML_API;
/
CREATE OR REPLACE PACKAGE BODY SGC.XML_API
AS
   PROCEDURE ERROR_PAGE (P_MESSAGE IN VARCHAR2);


   PROCEDURE DELETEEMPLOYEEBONUS (
      DATETIME       IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'yyyymmdd'),
      UNIQUENUMBER   IN VARCHAR2 DEFAULT NULL,
      P_NUIT         IN VARCHAR2 DEFAULT NULL,
      P_BI           IN VARCHAR2 DEFAULT NULL,
      P_EMPNUMBER    IN NUMBER DEFAULT NULL,
      P_FINDATE      IN VARCHAR2 DEFAULT NULL,
      P_EMPSTATUS    IN VARCHAR2 DEFAULT NULL)
   IS
      V_DATE         DATE;
      PS_COD_MASK    NUMBER;
      PS_NIS_RAD     NUMBER;
      PS_SEC_BONIF   NUMBER;
      PS_SEC_NIS     NUMBER;
      PS_COD_TAR     NUMBER;
      PS_RET_CODE    VARCHAR2 (2) := '00';
      PS_IND_ERR     NUMBER := 0;
      PS_COD_CLI     NUMBER;
   BEGIN
   
      IF (TRIM (DATETIME) IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Date not specified</desc></rowset>');
         RETURN;
      END IF;
      
            IF (TRIM (UNIQUENUMBER) IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> UNIQUENUMBER not specified</desc></rowset>');
         RETURN;
      END IF;
      
      IF (TRIM (P_NUIT) IS NULL AND TRIM (P_BI) IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Both NUIT and BI number not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_EMPNUMBER IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Employee number not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_FINDATE IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Fianalization date not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_EMPSTATUS IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Employee Status not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (TRIM (P_NUIT) IS NULL)
      THEN
         BEGIN
            SELECT COD_CLI
              INTO PS_COD_CLI
              FROM CLIENTES
             WHERE TIP_DOC = 'TD001' AND TRIM (DOC_ID) = P_BI;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               OWA_UTIL.MIME_HEADER ('text/xml');
               HTP.PRINT (
                  '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>01</code> <desc> No Customer in CMS (Search done by BI)</desc></rowset>');
               RETURN;
         END;
      ELSE
         BEGIN
            SELECT COD_CLI
              INTO PS_COD_CLI
              FROM CLIENTES
             WHERE TIP_DOC = 'TD007' AND TRIM (DOC_ID) = P_NUIT;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               OWA_UTIL.MIME_HEADER ('text/xml');
               HTP.PRINT (
                  '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>01</code> <desc> No Customer in CMS (Search done by NUIT)</desc></rowset>');
               RETURN;
         END;
      END IF;

      --get active

      BEGIN
         SELECT NIS_RAD,
                SEC_NIS,
                COD_TAR,
                COD_MASK
           INTO PS_NIS_RAD,
                PS_SEC_NIS,
                PS_COD_TAR,
                PS_COD_MASK
           FROM SUMCON S
          WHERE     COD_CLI = PS_COD_CLI
                AND EST_SUM LIKE 'EC01_'
                AND EXISTS
                       (SELECT 0
                          FROM BONIFICACIONES
                         WHERE     NIS_RAD = S.NIS_RAD
                               AND SEC_NIS = S.SEC_NIS
                               AND F_ANUL > TRUNC (SYSDATE)
                               AND CO_BONIF = 'BN004')
                AND TIP_SUMINISTRO = 'SU001';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            OWA_UTIL.MIME_HEADER ('text/xml');
            HTP.PRINT (
               '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>02</code> <desc> No Active Contract</desc></rowset>');
            RETURN;
      END;

      IF PS_COD_TAR <> 'E01'
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>03</code> <desc> No domestic tariff</desc></rowset>');
         RETURN;
      END IF;


      BEGIN
         SELECT NIS_RAD,
                SEC_NIS,
                COD_TAR,
                COD_MASK
           INTO PS_NIS_RAD,
                PS_SEC_NIS,
                PS_COD_TAR,
                PS_COD_MASK
           FROM SUMCON S
          WHERE     COD_CLI = PS_COD_CLI
                AND EST_SUM LIKE 'EC01_'
                AND EXISTS
                       (SELECT 0
                          FROM BONIFICACIONES
                         WHERE     NIS_RAD = S.NIS_RAD
                               AND SEC_NIS = S.SEC_NIS
                               AND F_ANUL < TRUNC (SYSDATE)
                               AND CO_BONIF = 'BN004')
                AND TIP_SUMINISTRO = 'SU001';

         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>02</code> <desc> Already unassigned bonus </desc></rowset>');
         RETURN;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            OWA_UTIL.MIME_HEADER ('text/xml');
            HTP.PRINT (
               '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>02</code> <desc> No Active Contract with Bonus</desc></rowset>');
            RETURN;
      END;

      SELECT SEC_BONIF
        INTO PS_SEC_BONIF
        FROM BONIFICACIONES
       WHERE     CO_BONIF = 'BN004'
             AND NIS_RAD = PS_NIS_RAD
             AND SEC_NIS = PS_SEC_NIS
             AND F_ANUL >= TRUNC (SYSDATE);


      UPDATE BONIFICACIONES
         SET F_ANUL = P_FINDATE
       WHERE     CO_BONIF = 'BN004'
             AND NIS_RAD = PS_NIS_RAD
             AND SEC_NIS = PS_SEC_NIS
             AND SEC_BONIF = PS_SEC_BONIF
             AND F_ANUL > TRUNC (SYSDATE);

      OWA_UTIL.MIME_HEADER ('text/xml');
      HTP.PRINT (
         '<?xml version="1.0"?><rowset>  <ind>1</ind>  <code>04</code> <desc> Bonus Deleted Successfully</desc></rowset>');
   END DELETEEMPLOYEEBONUS;

   PROCEDURE ADDEMPLOYEEBONUS (
      DATETIME       IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'yyyymmdd'),
      UNIQUENUMBER   IN VARCHAR2 DEFAULT NULL,
      P_NUIT         IN VARCHAR2 DEFAULT NULL,
      P_BI           IN VARCHAR2 DEFAULT NULL,
      P_EMPNUMBER    IN NUMBER DEFAULT NULL,
      P_EMPSTATUS    IN VARCHAR2 DEFAULT NULL,
      P_START_DATE   IN VARCHAR2 DEFAULT NULL,
      P_END_DATE     IN VARCHAR2 DEFAULT NULL)
   IS
      V_DATE         DATE;
      PS_COD_MASK    NUMBER;
      PS_FR_COUNT    NUMBER;
      PS_COUNT       NUMBER := 0;
      PS_NIS_RAD     NUMBER;
      PS_SEC_BONIF   NUMBER := 0;
      PS_COD_TAR     VARCHAR2 (3);
      PS_COD_CLI     NUMBER;
      PS_SEC_NIS     NUMBER;
      PS_RET_CODE    VARCHAR2 (3) := '05';
      PS_VALOR1      NUMBER;
      PS_VALOR2      NUMBER;
      PS_VALOR3      NUMBER;
   BEGIN
      IF (TRIM (P_NUIT) IS NULL AND P_BI IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> both NUIT and BI number not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_EMPNUMBER IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Employee number not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_EMPSTATUS IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Employee Status not specified</desc></rowset>');
         RETURN;
      END IF;

      IF (P_START_DATE IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Contract start date not stated</desc></rowset>');
         RETURN;
      END IF;


      IF (P_END_DATE IS NULL)
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Contract finalization date not stated</desc></rowset>');
         RETURN;
      END IF;


      IF (TRIM (P_NUIT) IS NULL)
      THEN
         BEGIN
            SELECT COD_CLI
              INTO PS_COD_CLI
              FROM CLIENTES
             WHERE TIP_DOC = 'TD001' AND TRIM (DOC_ID) = P_BI;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               OWA_UTIL.MIME_HEADER ('text/xml');
               HTP.PRINT (
                  '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>01</code> <desc> No Customer in CMS (Search done by BI)</desc></rowset>');
               RETURN;
         END;
      ELSE
         BEGIN
            SELECT COD_CLI
              INTO PS_COD_CLI
              FROM CLIENTES
             WHERE TIP_DOC = 'TD007' AND DOC_ID = P_NUIT;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               OWA_UTIL.MIME_HEADER ('text/xml');
               HTP.PRINT (
                  '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>01</code> <desc> No Customer in CMS (Search done by NUIT)</desc></rowset>');
               RETURN;
         END;
      END IF;

      BEGIN
         SELECT NIS_RAD,
                SEC_NIS,
                COD_TAR,
                COD_MASK
           INTO PS_NIS_RAD,
                PS_SEC_NIS,
                PS_COD_TAR,
                PS_COD_MASK
           FROM SUMCON S
          WHERE COD_CLI = PS_COD_CLI AND EST_SUM LIKE 'EC01_';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            OWA_UTIL.MIME_HEADER ('text/xml');
            HTP.PRINT (
               '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>02</code> <desc> No Active Contract</desc></rowset>');
            RETURN;
      END;

      IF PS_COD_TAR <> 'E01'
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset> <ind>0</ind>  <code>03</code> <desc> No domestic tariff</desc></rowset>');
         RETURN;
      END IF;


      BEGIN
         SELECT NVL (COUNT (*), 0)
           INTO PS_COUNT
           FROM SUMCON S
          WHERE     COD_CLI = PS_COD_CLI
                AND EST_SUM LIKE 'EC01_'
                AND EXISTS
                       (SELECT 0
                          FROM BONIFICACIONES
                         WHERE     NIS_RAD = S.NIS_RAD
                               AND SEC_NIS = S.SEC_NIS
                               AND F_ANUL > TRUNC (SYSDATE)
                               AND CO_BONIF = 'BN004')
                AND TIP_SUMINISTRO = 'SU001';

         IF PS_COUNT <> 0
         THEN
            OWA_UTIL.MIME_HEADER ('text/xml');
            HTP.PRINT (
               '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>04</code> <desc> Already assigned bonus </desc></rowset>');
            RETURN;
         END IF;
      END;

      -------temporary to confirm with esther/togara on status to be included (possibility to include in grupos_rel)
      SELECT NVL (COUNT (*), 0)
        INTO PS_FR_COUNT
        FROM ACTIV_FR AC
       WHERE     EXISTS
                    (SELECT 1
                       FROM TRABPEND_FR
                      WHERE     NUM_FR = AC.NUM_FR
                            AND NIS_RAD = PS_NIS_RAD
                            AND SEC_NIS = PS_SEC_NIS)
             AND ADD_MONTHS (F_IFR, 6) > SYSDATE
             AND EST_FR = 'FR002';

      -------temporary to confirm with esther/togara on status to be included (possibility to include in grupos_rel)


      IF PS_FR_COUNT > 0
      THEN
         OWA_UTIL.MIME_HEADER ('text/xml');
         HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> Fraud dedtected in the last six months</desc></rowset>');

         RETURN;
      END IF;

      SELECT NVL (MAX (SEC_BONIF), 0) + 1
        INTO PS_SEC_BONIF
        FROM BONIFICACIONES
       WHERE NIS_RAD = PS_NIS_RAD AND SEC_NIS = PS_SEC_NIS;


      PS_COUNT := 0;

      FOR REC IN (  SELECT *
                      FROM COD_VALOR
                     WHERE COD = 'BN004'
                  ORDER BY SEC_VALOR ASC)
      LOOP
         IF REC.SEC_VALOR = 1
         THEN
            PS_VALOR1 := REC.VALOR;
         END IF;

         IF REC.SEC_VALOR = 2
         THEN
            PS_VALOR2 := REC.VALOR;
         END IF;

         IF REC.SEC_VALOR = 3
         THEN
            PS_VALOR3 := REC.VALOR;
         END IF;

         PS_COUNT := PS_COUNT + 1;
      END LOOP;

      BEGIN
         --
         --      OWA_UTIL.mime_header ('text/xml');
         --         HTP.PRINT (
         --            '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>00</code> <desc> '||p_start_date||'</desc></rowset>');
         --
         --         RETURN;
         INSERT INTO BONIFICACIONES (NIS_RAD,
                                     SEC_NIS,
                                     SEC_BONIF,
                                     USUARIO,
                                     F_ACTUAL,
                                     PROGRAMA,
                                     F_VAL,
                                     F_ANUL,
                                     CO_BONIF,
                                     BONIF_VALOR,
                                     BONIF_PORC,
                                     BONIF_MAX,
                                     BONIF_TOTAL,
                                     BONIF_DISP,
                                     CO_CONCEPTO,
                                     PRIORIDAD,
                                     IND_REL,
                                     DATOS,
                                     COD1,
                                     COD2)
              VALUES (
                        PS_NIS_RAD,
                        PS_SEC_NIS,
                        PS_SEC_BONIF,
                        USER,
                        SYSDATE,
                        'HR_INTERFACE',
                        TO_DATE (P_START_DATE, 'yyyymmdd'),
                        TO_DATE (P_END_DATE, 'YYYYMMDD'),
                        'BN004',
                        PS_VALOR1,
                        PS_VALOR2,
                        PS_VALOR3,
                        0,
                        0,
                        'CC904',
                        10,
                        1,
                           '/1/8/'
                        || TO_CHAR (SYSDATE, 'yyyymmdd')
                        || '/KD001/'
                        || P_EMPNUMBER
                        || '/'
                        || TO_CHAR (SYSDATE, 'yyyymmdd')
                        || '/GIAF_INTERFACE/1/'
                        || USER
                        || '/'
                        || TO_CHAR (SYSDATE, 'yyyymmdd')
                        || '/',
                        'KG001',
                        'KP001');
      EXCEPTION
         WHEN OTHERS
         THEN
            OWA_UTIL.MIME_HEADER ('text/xml');
            HTP.PRINT (
                  '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>'
               || SQLCODE
               || '</code> <desc> Failed to create bonus ERR. MSG:'
               || SQLERRM
               || ' </desc></rowset>');

            RETURN;
      END;

      PS_COUNT := 1;

      FOR REC1
         IN (SELECT *
               FROM GRUPOS_REL
              WHERE     COD_GRUPO = 'BN004'
                    AND BITAND (PS_COD_MASK, COD_MASK) > 0)
      LOOP
         BEGIN
            INSERT INTO SGC.BONIF_CONCEPTO (NIS_RAD,
                                            SEC_NIS,
                                            SEC_BONIF,
                                            SEC_CONCEPTO,
                                            USUARIO,
                                            F_ACTUAL,
                                            PROGRAMA,
                                            CO_CONCEPTO)
                 VALUES (PS_NIS_RAD,
                         PS_SEC_NIS,
                         PS_SEC_BONIF,
                         PS_COUNT,
                         USER,
                         SYSDATE,
                         'GIAF_INTERFACE',
                         REC1.CODIGO);


            PS_COUNT := PS_COUNT + 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               OWA_UTIL.MIME_HEADER ('text/xml');
               HTP.PRINT (
                     '<?xml version="1.0"?><rowset>  <ind>0</ind>  <code>'
                  || SQLCODE
                  || '</code> <desc> Failed to create bonus concept ERR. MSG:'
                  || SQLERRM
                  || ' </desc></rowset>');
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      OWA_UTIL.MIME_HEADER ('text/xml');
      HTP.PRINT (
         '<?xml version="1.0"?><rowset>  <ind>1</ind>  <code>04</code> <desc> Bonus Created Successfully</desc></rowset>');
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         ERROR_PAGE (SQLERRM);
   END ADDEMPLOYEEBONUS;



   PROCEDURE ERROR_PAGE (P_MESSAGE IN VARCHAR2)
   AS
   BEGIN
      OWA_UTIL.MIME_HEADER ('text/xml');
      HTP.PRINT (
            '<?xml version="1.0"?><rowset>  <ind>0</ind><code>'
         || DBMS_XMLGEN.CONVERT (P_MESSAGE)
         || '</code>'
         || '</rowset>');
   END ERROR_PAGE;
END XML_API;
/
