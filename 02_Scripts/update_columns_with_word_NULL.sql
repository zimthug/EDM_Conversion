begin
  /**
   *  Tables loaded from Access and Excel have the word 'NULL' for null columns
   *  This code will update them to null values
   *  @author tmlangeni@eservicios.indracompany.com
   */
  for x in (select *
              from all_tab_columns
             where table_name = 'CADASTRAMENTO'
               and data_type = 'VARCHAR2') loop
    execute immediate (' update ' || x.owner || '.' || x.table_name ||
                      ' set ' || x.column_name || ' = null where ' ||
                      x.column_name || ' = ''NULL''');
    commit;
  end loop;
end;
