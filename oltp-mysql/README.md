# OLTP MySQL

## Propósito

Esta carpeta contiene el origen transaccional del proyecto `farmacia-bi`.

Aquí viven:

- la base `farmadb` en MySQL
- el script de inicialización del OLTP
- la fase manual de la sesión 1

## Rol en la arquitectura

```text
MySQL (farmadb) -> Airbyte o ETL manual -> DataMart / DW
```

## Configuración clave

- motor: `MySQL 8.4`
- contenedor: `farmacia-oltp-mysql`
- host: `localhost`
- puerto: `13306`
- base: `farmadb`
- usuario: `root`
- password: `root`

Script base del OLTP:

- `mysql/init/farmadb.sql`

## Operación mínima

Levantar el servicio:

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

Acceso opcional al motor:

```powershell
docker exec -it farmacia-oltp-mysql mysql -uroot -proot farmadb
```

## Scripts del DataMart manual

Orden recomendado:

1. `1_dm.sql`
2. `2_G_pasos.sql`
3. `3_poblar.sql`

Uso de cada script:

- `1_dm.sql`: crea dimensiones y tabla de hechos del DataMart manual
- `2_G_pasos.sql`: explica la construcción pedagógica de la vista `G`
- `3_poblar.sql`: carga dimensiones, `vw_g_ventas` y `fact_ventas`

## Validación mínima

Dentro de MySQL puedes validar:

```sql
show tables;
select count(*) from pedidos;
select count(*) from pedido_detalles;
```

## Integración

- este módulo es la fuente para `ingesta-airbyte/`
- en la sesión 1 también se usa directamente para el ETL manual

## Guías relacionadas

- [SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md](SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md)
- [SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md](SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md)
- [SESION_U2_S1_P3_VALIDACION_ANALITICA_DEL_DATAMART_MANUAL.md](SESION_U2_S1_P3_VALIDACION_ANALITICA_DEL_DATAMART_MANUAL.md)
