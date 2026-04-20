# farmacia-bi

Laboratorio BI para construir un flujo completo desde una base transaccional hasta un DW/DataMart explotable en Power BI.

Flujo general del proyecto:

```text
MySQL OLTP -> Airbyte -> PostgreSQL DW -> dbt -> Power BI
```

## Estructura del proyecto

```text
farmacia-bi/
├── oltp-mysql/
├── dw-pg/
├── ingesta-airbyte/
├── dw-dbt/
└── powerbi/
```

## Que contiene cada carpeta

- `oltp-mysql/`: origen transaccional MySQL con la base `farmadb` y la fase manual del DW.
- `dw-pg/`: PostgreSQL analitico con la base `farmacia_dw`.
- `ingesta-airbyte/`: documentacion y guias de ingesta batch con Airbyte.
- `dw-dbt/`: proyecto dbt para construir `staging` y `marts`.
- `powerbi/`: espacio para la capa semantica, explotacion analitica y dashboard final.

## Arquitectura logica

- `farmadb` en MySQL representa el OLTP.
- Airbyte replica desde MySQL hacia PostgreSQL.
- PostgreSQL se organiza en tres schemas:
  - `raw`: aterrizaje de Airbyte.
  - `staging`: limpieza y homologacion con dbt.
  - `marts`: dimensiones y hechos del DataMart.

## Unidad 2 congelada

La Unidad 2 queda organizada en dos sesiones principales:

- `Sesion 6 - Implementacion manual del DW con SQL`
  - ETL manual, transformacion, carga y validacion analitica.
- `Sesion 7 - Implementacion del pipeline BI con herramientas`
  - ingesta, transformacion, carga y optimizacion.

Documentos de apoyo creados en la raiz:

- [UNIDAD_2_SESION_1.md](/c:/261bi/farmacia-bi/UNIDAD_2_SESION_1.md)
- [UNIDAD_2_SESION_2.md](/c:/261bi/farmacia-bi/UNIDAD_2_SESION_2.md)
- [UNIDAD_2_ESTRUCTURA_GUIAS.md](/c:/261bi/farmacia-bi/UNIDAD_2_ESTRUCTURA_GUIAS.md)

## Mapa de guias por carpeta

```text
farmacia-bi/
├── oltp-mysql/
│   ├── SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md
│   ├── SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md
│   └── SESION_U2_S1_P3_VALIDACION_ANALITICA_DEL_DATAMART_MANUAL.md
├── dw-pg/
├── ingesta-airbyte/
│   └── SESION_U2_S2_P1_INGESTA_BATCH_CON_AIRBYTE_DE_MYSQL_A_POSTGRESQL.md
├── dw-dbt/
│   ├── SESION_U2_S2_P2_IMPLEMENTACION_DE_STAGING_CON_DBT_EN_POSTGRESQL.md
│   └── SESION_U2_S2_P3_IMPLEMENTACION_DEL_DATAMART_CON_DBT_EN_POSTGRESQL.md
└── powerbi/
```

## Orden recomendado de trabajo tecnico

### 1. Levantar el OLTP MySQL

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

Verificacion opcional:

```powershell
docker exec -it farmacia-oltp-mysql mysql -uroot -proot farmadb
```

### 2. Levantar el PostgreSQL del DW

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose up -d
docker compose ps
```

Verificacion opcional:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Dentro de PostgreSQL valida los schemas:

```sql
\dn
```

Debes ver:

- `raw`
- `staging`
- `marts`

### 3. Configurar Airbyte para aterrizar en `raw`

En este laboratorio Airbyte se usa como instalacion separada y manual.

Abre en el navegador:

```text
http://localhost:8010
```

#### Source MySQL

- Host: `host.docker.internal`
- Port: `13306`
- Database: `farmadb`
- Username: `root`
- Password: `root`

#### Destination PostgreSQL

- Host: `host.docker.internal`
- Port: `15432`
- Database: `farmacia_dw`
- Schema: `raw`
- Username: `postgres`
- Password: `postgres`

#### Configuracion de la conexion

Para este laboratorio, si las tablas no tienen un buen campo cursor, trabaja con:

- `Full refresh | Overwrite`

Luego ejecuta:

- `Sync now`

### 4. Validar que Airbyte cargo datos en `raw`

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Dentro de PostgreSQL:

```sql
\dt raw.*
SELECT * FROM raw.categorias LIMIT 10;
SELECT * FROM raw.productos LIMIT 10;
SELECT * FROM raw.pedidos LIMIT 10;
```

### 5. Levantar el entorno dbt

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
docker compose up -d --build
docker compose ps
```

Ingresar al contenedor:

```powershell
docker exec -it farmacia-dw-dbt bash
```

### 6. Ejecutar dbt

Dentro del contenedor:

```bash
cd /usr/app/farmacia_bi
dbt debug
dbt run --select staging
dbt run --select +marts
dbt run --select +fact_ventas
```

### 7. Validar el DataMart final

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Dentro de PostgreSQL:

```sql
\dv staging.*
\dt marts.*
SELECT * FROM marts.dim_cliente LIMIT 10;
SELECT * FROM marts.dim_vendedor LIMIT 10;
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.dim_fecha LIMIT 10;
SELECT * FROM marts.dim_estado_pedido LIMIT 10;
SELECT * FROM marts.fact_ventas LIMIT 20;
```

## Nota importante

Trabaja ya con la estructura nueva del proyecto:

- `oltp-mysql/`
- `dw-pg/`
- `ingesta-airbyte/`
- `dw-dbt/`
- `powerbi/`

Si todavia ves carpetas antiguas de etapas previas, tomalo solo como historico y no las uses para el laboratorio actual.
