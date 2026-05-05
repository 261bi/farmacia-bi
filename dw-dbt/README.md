# DW dbt

## Propósito

Este directorio contiene el proyecto `dbt` que transforma la capa `raw` y construye el modelo estrella final.

## Rol en la arquitectura

```text
MySQL -> Airbyte -> PostgreSQL raw -> dbt staging -> dbt marts
```

## Prerequisitos

Antes de usar este módulo deben estar operativos:

- `dw-pg/` con la base `farmacia_dw`
- `raw` cargado por Airbyte

## Configuración clave

- contenedor: `farmacia-dw-dbt`
- proyecto dbt: `farmacia_bi`
- profile: `.dbt/profiles.yml`
- schema base del target: `marts`

Capas del proyecto:

- `staging`: vistas limpias y homologadas
- `marts`: dimensiones y hecho final

## Operación mínima

Levantar el contenedor:

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
docker compose up -d --build
docker compose ps
```

Ingresar:

```powershell
docker exec -it farmacia-dw-dbt bash
```

Dentro del contenedor:

```bash
cd /usr/app/farmacia_bi
dbt debug
dbt run --select staging
dbt run --select +marts
dbt test --select marts
```

## Validación mínima

En PostgreSQL:

```sql
\dv staging.*
\dt marts.*
select * from marts.fact_ventas limit 20;
```

## Integración

- consume `raw` desde `dw-pg/`
- construye `staging` y `marts`
- deja listo el modelo para `powerbi/`

## Guías relacionadas

- [SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)
- [SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)
