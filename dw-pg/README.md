# DW PostgreSQL

## Proposito

Esta carpeta contiene la base PostgreSQL que aloja el `Data Warehouse` y el `DataMart` del proyecto.

## Rol en la arquitectura

```text
MySQL -> Airbyte -> PostgreSQL (raw, staging, marts) -> dbt -> Power BI
```

## Configuracion clave

- motor: `PostgreSQL 16`
- contenedor: `farmacia-dw-pg`
- host: `localhost`
- puerto: `15432`
- base: `farmacia_dw`
- usuario: `postgres`
- password: `postgres`

Schemas esperados:

- `raw`
- `staging`
- `marts`

Script de inicializacion:

- `postgres/init/01_create_schemas.sql`

## Operacion minima

Levantar el servicio:

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose up -d
docker compose ps
```

Acceso opcional al motor:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

## Validacion minima

Dentro de PostgreSQL:

```sql
\dn
\dt raw.*
\dv staging.*
\dt marts.*
```

## Integracion

- `ingesta-airbyte/` aterriza datos en `raw`
- `dw-dbt/` transforma `raw` hacia `staging` y `marts`
- `powerbi/` consume principalmente `marts`

## Guias relacionadas

- [../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
- [../dw-dbt/SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](../dw-dbt/SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)
- [../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)
