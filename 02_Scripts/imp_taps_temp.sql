d:\Oracle\tmlangeni\product\11.2\BIN\impdp directory=DATA_PUMP_DIR dumpfile=exp_EDMCONV_20140516.dmp logfile=exp_EDMCONV_20140516_loading.log schemas=(sgc,intfopen,open_u,rep,dep) remap_tablespace=(DEP_DATOS:DATOS,DEP_INDICES:INDICES,IDATOS:DATOS,IINDICES:INDICES,INDICES:INDICES,OP_STAT:DATOS,REP_DATA:DATOS,REP_IND:INDICES,REP_TMP:DATOS,TOOLS:DATOS)

d:\Oracle\tmlangeni\product\11.2\BIN\imp file=edmconv_20140516.dmp log=edmconv_20140516_loading.log schemas=(edmgalatee,edmaccess,edmeclipse,edmcamp,convis)

d:\Oracle\tmlangeni\product\11.2\BIN\imp file=edmconv_20140516.dmp log=edmconv_20140516_loading.log fromuser=(edmgalatee,edmaccess,edmcamp,edmeclipse,convis) touser=(edmgalatee,edmaccess,edmcamp,edmeclipse,convis) ignore=y


d:\Oracle\tmlangeni\product\11.2\BIN\imp file=edmconv_20140516.dmp log=edmconv_20140516_loading.log fromuser=(edmgalatee) touser=(edmgalatee) ignore=y
