# Sesion U2 S2 P2: dbt para modelado fisico del DataMart

## 1. Titulo

Implementacion del modelado fisico del DataMart sobre PostgreSQL usando dbt.

## 2. Objetivo

Levantar y validar el entorno `dbt` para continuar la construccion del `Data Warehouse` y del `DataMart`, usando como entrada la capa `raw` cargada previamente por Airbyte.

Al finalizar la sesion, el alumno debe poder:

- levantar el contenedor de `dbt`
- acceder al contenedor
- verificar la instalacion de `dbt-core` y `dbt-postgres`
- comprender el papel de `dbt` en la arquitectura analitica
- construir la capa `staging`
- construir dimensiones y el hecho principal del DataMart

## 3. Herramientas utilizadas

- Docker Compose
- Docker
- dbt Core
- dbt Postgres
- PostgreSQL
- PowerShell

## 4. Flujo de arquitectura

```text
MySQL -> Airbyte -> PostgreSQL raw -> dbt staging -> dbt marts
```

## 5. Capas del proyecto

- `raw`
  - contiene tablas aterrizadas por Airbyte
  - conserva la estructura del origen transaccional
- `staging`
  - limpia, tipa, renombra y estandariza datos
- `marts`
  - contiene dimensiones y hechos
  - implementa el modelo estrella final

Equivalencia conceptual:

- `raw` = `Bronze`
- `staging` = `Silver`
- `marts` = `Gold`

### 5.1 Donde encaja SCD (Slowly Changing Dimensions) en esta sesion

En una arquitectura moderna, `SCD` pertenece al modelado dimensional dentro del DW.

En esta sesion:

- dbt decide como modelar las dimensiones en `marts`
- por eso, conceptualmente, `SCD` ocurre aqui
- en esta version del laboratorio se trabaja una primera estrella base

## 6. Mapa actual del OLTP `farmadb`

Esta practica usa el esquema renombrado actual definido en:

- [farmadb.sql](../oltp-mysql/mysql/init/farmadb.sql)

Tablas fuente relevantes del OLTP:

- `clientes`
- `vendedores`
- `familias`
- `categorias`
- `productos`
- `pedidos`
- `pedido_detalles`

Mapeos reales ya implementados en `dbt`:

- `raw.pedidos.id` -> `stg_pedidos.pedido_id`
- `raw.pedidos.estado` -> `stg_pedidos.estado_pedido`
- `raw.productos.id` -> `stg_productos.producto_id`
- `raw.productos.codigo` -> `stg_productos.codigo_producto`
- `raw.productos.nombre` -> `stg_productos.nombre_producto_base`

## 7. Modelos reales del proyecto `dbt`

### 7.1 Staging

- `stg_clientes`
- `stg_vendedores`
- `stg_familias`
- `stg_categorias`
- `stg_productos`
- `stg_pedidos`
- `stg_pedido_detalles`

### 7.2 Marts

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`
- `fact_ventas`

Importante:

- `dim_producto` queda denormalizada
- `categoria` y `familia` no quedan como dimensiones separadas
- `dim_estado_pedido` usa `estado_pedido_key`
- `fact_ventas` usa el grano de una fila por linea de pedido por producto

## 8. Desarrollo de la practica

### 8.1 Ubicate en el directorio de dbt

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
```

### 8.2 Construye y levanta el contenedor

```powershell
docker compose down
docker compose up -d --build
docker compose ps
```

### 8.3 Ingresa al contenedor

```powershell
docker exec -it farmacia-dw-dbt bash
```

Luego:

```bash
cd /usr/app/farmacia_bi
```

### 8.4 Verifica la instalacion y configuracion

```bash
dbt --version
dbt debug
```

### 8.5 Ejecuta la capa `staging`

```bash
dbt run --select staging
```

### 8.6 Ejecuta la capa `marts`

```bash
dbt run --select marts
```

### 8.7 Valida la estrella final en PostgreSQL

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego:

```sql
\dv staging.*
\dt marts.*
SELECT * FROM staging.stg_pedidos LIMIT 10;
SELECT * FROM staging.stg_pedido_detalles LIMIT 10;
SELECT * FROM marts.dim_cliente LIMIT 10;
SELECT * FROM marts.dim_vendedor LIMIT 10;
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.dim_fecha LIMIT 10;
SELECT * FROM marts.dim_estado_pedido LIMIT 10;
SELECT * FROM marts.fact_ventas LIMIT 20;
```

## 9. Grano y claves del hecho actual

`fact_ventas` se construyo con este grano:

- una fila por linea de pedido por producto

Claves dimensionales usadas en el proyecto actual:

- `fecha_key`
- `cliente_key`
- `vendedor_key`
- `producto_key`
- `estado_pedido_key`

Campos de trazabilidad conservados:

- `pedido_id`
- `producto_id`

## 10. Evidencias a entregar

- captura de `docker compose ps`
- captura de la salida de `dbt --version`
- captura de `dbt debug` exitoso
- captura de `dbt run --select staging`
- captura de `dbt run --select marts`
- captura de `marts.fact_ventas` consultada en PostgreSQL

## 11. Cierre

En esta sesion queda validado que:

- `staging` se construye por tabla fuente del OLTP
- `marts` implementa la estrella final del caso
- `fact_ventas` integra cabecera, detalle y dimensiones
- el DataMart fisico base queda listo para validacion analitica
