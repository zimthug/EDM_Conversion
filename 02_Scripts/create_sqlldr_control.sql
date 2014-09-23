select rpad(column_name, 50, ' ') ||
        decode(data_type, 'DATE', ' DATE "YYYY-MM-DD",', '                 ,')
  from dba_tab_columns
 where owner = 'EDMGALATEE'
   and table_name = 'CLIENT'
 order by column_id;

select rpad(column_name, 50, ' ') ||
        decode(data_type, 'DATE', ' DATE "DD/MM/YYYY HH24:MI:SS",', 'NUMBER',
               ' "REPLACE(:' || column_name || ', ''$'', null)",',
               '                 ,')
  from dba_tab_columns
 where owner = 'EDMACCESS'
   and table_name = 'FACTURACAO'
 order by column_id;
