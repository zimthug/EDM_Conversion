begin
  for x in (select *
              from all_constraints
             where owner in ('OPEN_U', 'SGC', 'INTFOPEN')
               and constraint_type = 'R'
               and status = 'ENABLED') loop
    execute immediate ('alter table ' || x.owner || '.' || x.table_name ||
                      ' disable constraint ' || x.constraint_name);
  end loop;
end;
/

truncate table intfopen.fincas;

truncate table intfopen.clientes;

truncate table sgc.cuentas_cu;

truncate table intfopen.personal;

truncate table intfopen.sumcon;

delete bonificaciones;

truncate table sgc.rel_nis_rutafol;

truncate table sgc.sumcon_log;

truncate table sgc.account_assoc;

truncate table sgc.recibos;

truncate table sgc.hfacturacion;

truncate table sgc.imp_concepto;

truncate table sgc.est_rec;

truncate table sgc.cargvar;

truncate table sgc.fincas_per_lect;

truncate table sgc.rutas;

truncate table sgc.mitin;

truncate table sgc.ciclos_itin;

truncate table sgc.ciclos_ruta;

truncate table sgc.bdg_movimientos;

truncate table sgc.sumcon_log;

truncate table sgc.apmedida_co;

truncate table sgc.imp_concepto;

truncate table sgc.recibos;

truncate table sgc.account_assoc;

truncate table sgc.est_rec;

truncate table sgc.hfacturacion;

truncate table intfopen.apmedida_ap;

truncate table intfopen.puntomed;

truncate table intfopen.puntomed_param;

truncate table sgc.aparatos;

truncate table sgc.haparatos;

truncate table sgc.conc_tecnicos;

truncate table sgc.sie_asientos_det;

truncate table sgc.pagos_concepto;

truncate table sgc.imp_detalle_concepto;

truncate table sgc.rel_nis_rutafol;

truncate table sgc.imprimir_datos;

truncate table sgc.sie_param_alias_account;

truncate table sgc.sie_pagos;

truncate table sgc.pagos;

truncate table sgc.ord_actividades;

truncate table sgc.apmedida_param;

truncate table sgc.sie_transactions;

truncate table intfopen.ordenes;

truncate table sgc.sie_asientos;

truncate table sgc.cobtemp;

truncate table sgc.fincas_per_lect;

truncate table intfopen.actividades;

truncate table sgc.ordenes_lect;

truncate table intfopen.hpersonal;

truncate table sgc.hapmedida_co;

truncate table sgc.sie_cuotas_pl;

truncate table sgc.gestiones_cobro;

truncate table sgc.coberror;

truncate table sgc.hapmedida_param;

truncate table intfopen.expedientes;

truncate table intfopen.expedientes_sum;

truncate table sgc.movcaja;

/*
delete sgc.municipios_lixo;

delete deptos;

delete municipios;

delete localidades;

delete callejero;*/

begin
  for x in (select *
              from all_constraints
             where owner in ('OPEN_U', 'SGC', 'INTFOPEN')
               and constraint_type = 'R') loop
    begin
      execute immediate ('alter table ' || x.owner || '.' || x.table_name ||
                        ' enable constraint ' || x.constraint_name);
    exception
      when others then
        null;
    end;
  end loop;
end;
/
