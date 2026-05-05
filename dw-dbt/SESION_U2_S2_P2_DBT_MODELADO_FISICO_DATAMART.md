# Sesión U2 S2 P2: dbt para modelado físico del DataMart

## 1. Título

Implementación del modelado físico del DataMart sobre PostgreSQL usando dbt.

## 2. Objetivo

Levantar y validar el entorno `dbt` para continuar la construcción del `Data Warehouse` y del `DataMart`, usando como entrada la capa `raw` cargada previamente por Airbyte.

Al finalizar la sesión, el alumno debe poder:

- levantar el contenedor de `dbt`
- acceder al contenedor
- verificar la instalación de `dbt-core` y `dbt-postgres`
- comprender el papel de `dbt` en la arquitectura analítica
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

### 5.1 Dónde encaja SCD (Slowly Changing Dimensions) en esta sesión

En una arquitectura moderna, `SCD` pertenece al modelado dimensional dentro del DW.

En esta sesión:

- dbt decide como modelar las dimensiones en `marts`
- por eso, conceptualmente, `SCD` ocurre aquí
- en esta versión del laboratorio se trabaja una primera estrella base

## 6. Mapa actual del OLTP `farmadb`

Esta práctica usa el esquema renombrado actual definido en:

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
- `fact_ventas` usa el grano de una fila por línea de pedido por producto

## 8. Desarrollo de la práctica

### 8.1 Ubícate en el directorio de dbt

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
```

### 8.2 Construye y levanta el contenedor

```powershell
docker compose down
docker compose up -d --build
docker compose ps
```

Resultado esperado:

- el servicio `dbt` aparece en estado `Up`

### 8.3 Ingresa al contenedor

```powershell
docker exec -it farmacia-dw-dbt bash
```

Luego:

```bash
cd /usr/app/farmacia_bi
```

### 8.4 Verifica la instalación de dbt

```bash
dbt --version
```

Aquí debes confirmar que están instalados:

- `dbt-core`
- `dbt-postgres`

### 8.5 Verifica la configuración con `dbt debug`

```bash
dbt debug
```

#### ¿Qué hace `dbt debug`?

Antes de ejecutar modelos, conviene entender dos archivos base del proyecto:

- `profiles.yml`
- `dbt_project.yml`

### 8.5.0 Cómo entender `profiles.yml` y `dbt_project.yml`

Piénsalo como una separación de responsabilidades:

```text
profiles.yml
    -> conexion
    -> host
    -> puerto
    -> usuario
    -> password
    -> base de datos
    -> schema base del target

dbt_project.yml
    -> organizacion del proyecto
    -> carpetas de modelos
    -> materializacion
    -> schema por capa
```

En este laboratorio:

```text
profiles.yml    = a que PostgreSQL se conecta dbt
dbt_project.yml = como dbt construye staging y marts
```

#### Ejemplo de `profiles.yml`

```yaml
farmacia_bi:
  target: dev
  outputs:
    dev:
      type: postgres
      host: farmacia-dw-pg
      user: postgres
      password: postgres
      port: 5432
      dbname: farmacia_dw
      schema: marts
      threads: 1
```

Lectura pedagógica:

- `host: farmacia-dw-pg`
  - dbt se conecta al contenedor PostgreSQL
- `dbname: farmacia_dw`
  - esta es la base analítica donde se construyen los modelos
- `schema: marts`
  - este es el schema base del target actual
- `target: dev`
  - dbt usa la salida `dev` al ejecutar comandos como `dbt debug` o `dbt run`

#### Ejemplo de `dbt_project.yml`

```yaml
models:
  farmacia_bi:
    staging:
      +materialized: view
      +schema: staging
    marts:
      +materialized: table
      +schema: marts
```

Lectura pedagógica:

- `staging`
  - sus modelos se construyen como vistas
  - deben vivir en el schema `staging`
- `marts`
  - sus modelos se construyen como tablas
  - deben vivir en el schema `marts`

#### Figura resumen

```text
profiles.yml
    -> conecta dbt a farmacia_dw
    -> define el target activo
    -> aporta el schema base

dbt_project.yml
    -> define que staging sea view
    -> define que marts sea table
    -> separa los modelos por schema

generate_schema_name.sql
    -> evita que dbt concatene marts + staging
    -> permite usar staging y marts como schemas reales separados
```

`dbt debug` verifica que el proyecto esté listo para trabajar.

En particular, valida:

- que `profiles.yml` exista y sea valido
- que `dbt_project.yml` exista y sea valido
- que `dbt` pueda conectarse a PostgreSQL
- que el entorno base del proyecto este correctamente configurado
- que el target activo apunte a la base, host, puerto y schema esperados

Interpretación didactica:

- `dbt --version` responde a la pregunta: "¿dbt está instalado?"
- `dbt debug` responde a la pregunta: "¿dbt está listo para trabajar con este proyecto y esta base?"

Si `dbt debug` falla, no conviene avanzar a `dbt run`, porque el problema todavía está en la configuración del entorno.

### 8.5.1 Nota importante sobre schemas en dbt

En este proyecto, `profiles.yml` define:

```yaml
schema: marts
```

Ese valor funciona como schema base del target activo.

Por defecto, si en `dbt_project.yml` un grupo de modelos usa:

```yaml
+schema: staging
```

dbt no siempre crea directamente `staging.stg_clientes`, sino que puede concatenar ambos nombres y terminar creando:

```text
marts_staging.stg_clientes
```

Para evitarlo, el proyecto incluye la macro:

- `macros/generate_schema_name.sql`

Esa macro hace que:

- los modelos de `staging` se creen en el schema real `staging`
- los modelos de `marts` se creen en el schema real `marts`

Entonces, al ejecutar:

```bash
dbt run --select stg_clientes
```

lo esperado es que dbt cree una vista:

```text
staging.stg_clientes
```

y no una vista en `marts_staging`.

### 8.6 Revisa primero la capa `raw`

Antes de transformar, confirma que las tablas esperadas ya llegaron desde Airbyte.

Desde otra terminal, fuera del contenedor `dbt`, ejecuta:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego valida:

```sql
\dt raw.*
SELECT * FROM raw.clientes LIMIT 10;
SELECT * FROM raw.vendedores LIMIT 10;
SELECT * FROM raw.familias LIMIT 10;
SELECT * FROM raw.categorias LIMIT 10;
SELECT * FROM raw.productos LIMIT 10;
SELECT * FROM raw.pedidos LIMIT 10;
SELECT * FROM raw.pedido_detalles LIMIT 10;
```

### 8.7 Construye la capa `staging` paso a paso

Antes de correr toda la carpeta `staging`, conviene entender como están hechos los modelos.

Modelos base:

- `stg_clientes`
  - toma `raw.clientes`
  - renombra `id` a `cliente_id`
  - renombra `nombre` a `nombre_cliente`
- `stg_vendedores`
  - toma `raw.vendedores`
  - renombra `id` a `vendedor_id`
  - renombra `nombre` a `nombre_vendedor`
- `stg_familias`
  - toma `raw.familias`
  - renombra `id` a `familia_id`
  - renombra `nombre` a `nombre_familia`
- `stg_categorias`
  - toma `raw.categorias`
  - renombra `id` a `categoria_id`
  - renombra `nombre` a `nombre_categoria`
- `stg_productos`
  - toma `raw.productos`
  - renombra claves y atributos principales
  - integra categoría y familia
  - construye `nombre_producto`
- `stg_pedidos`
  - toma `raw.pedidos`
  - renombra `id` a `pedido_id`
  - renombra `estado` a `estado_pedido`
- `stg_pedido_detalles`
  - toma `raw.pedido_detalles`
  - conserva el detalle transaccional base del hecho

### 8.8 Ejecuta primero un modelo simple de `staging`

Para no saltar directamente a todo el proyecto, ejecuta primero un modelo sencillo.

Ejemplo:

```bash
dbt run --select stg_clientes
```

Luego valida en PostgreSQL:

```sql
\dv staging.*
SELECT * FROM staging.stg_clientes LIMIT 10;
```

Importante:

- `stg_clientes` esta materializado como `view`
- por eso dbt debe crear una vista, no una tabla
- si ves un schema como `marts_staging`, revisa la macro `generate_schema_name.sql`

### 8.9 Ejecuta toda la capa `staging`

```bash
dbt run --select staging
```

Resultado esperado:

- se crean las vistas `stg_*` en el schema `staging`

### 8.10 Valida `staging`

```sql
SELECT * FROM staging.stg_clientes LIMIT 10;
SELECT * FROM staging.stg_vendedores LIMIT 10;
SELECT * FROM staging.stg_familias LIMIT 10;
SELECT * FROM staging.stg_categorias LIMIT 10;
SELECT * FROM staging.stg_productos LIMIT 10;
SELECT * FROM staging.stg_pedidos LIMIT 10;
SELECT * FROM staging.stg_pedido_detalles LIMIT 10;
```

Debes comprobar:

- que los nombres fueron homologados
- que `stg_pedidos` ya usa `pedido_id` y `estado_pedido`
- que `stg_productos` ya expone `producto_id`, `codigo_producto`, `nombre_producto` y la jerarquía comercial

### 8.11 Ejecuta la capa `marts`

Antes de ejecutar toda la carpeta `marts`, conviene entender que tipo de modelos contiene.

Dimensiones actuales:

- `dim_cliente`
  - toma `stg_clientes`
  - usa `cliente_id` como `cliente_key`
- `dim_vendedor`
  - toma `stg_vendedores`
  - usa `vendedor_id` como `vendedor_key`
- `dim_producto`
  - toma `stg_productos`
  - usa `producto_id` como `producto_key`
  - conserva `codigo_producto`, `nombre_producto`, categoría y familia
- `dim_fecha`
  - toma fechas distintas desde `stg_pedidos`
  - construye `fecha_key` con formato `YYYYMMDD`
- `dim_estado_pedido`
  - toma estados distintos desde `stg_pedidos`
  - construye `estado_pedido_key`

Hecho actual:

- `fact_ventas`
  - integra `stg_pedidos` con `stg_pedido_detalles`
  - se conecta a las dimensiones
  - calcula medidas comerciales y tiempos operativos

### 8.12 Ejecuta primero una dimension simple

Para no saltar directamente a toda la estrella, ejecuta primero una dimension sencilla.

Ejemplo:

```bash
dbt run --select dim_cliente
```

Luego valida:

```sql
SELECT * FROM marts.dim_cliente LIMIT 10;
```

### 8.13 Ejecuta la dimension de producto

Esta dimension es importante porque ya incorpora la denormalizacion de categoría y familia.

```bash
dbt run --select dim_producto
```

Luego valida:

```sql
SELECT * FROM marts.dim_producto LIMIT 10;
```

Debes comprobar:

- `producto_key`
- `producto_id`
- `codigo_producto`
- `nombre_producto`
- `categoria_id`
- `nombre_categoria`
- `familia_id`
- `nombre_familia`

### 8.14 Ejecuta las dimensiones restántes

```bash
dbt run --select dim_vendedor dim_fecha dim_estado_pedido
```

Luego valida:

```sql
SELECT * FROM marts.dim_vendedor LIMIT 10;
SELECT * FROM marts.dim_fecha LIMIT 10;
SELECT * FROM marts.dim_estado_pedido LIMIT 10;
```

### 8.15 Ejecuta el hecho principal

Antes de correrlo, recuerda el grano oficial del proyecto:

- una fila por línea de pedido por producto

Ahora ejecuta:

```bash
dbt run --select fact_ventas
```

Luego valida:

```sql
SELECT * FROM marts.fact_ventas LIMIT 20;
```

### 8.16 Ejecuta toda la capa `marts`

Una vez validados los modelos principales por separado, ya puedes ejecutar toda la carpeta:

```bash
dbt run --select +marts
```

Resultado esperado:

- se crean dimensiones y hecho en el schema `marts`

### 8.17 Valida la estrella final en PostgreSQL

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

### 8.18 Qué debes observar en `fact_ventas`

Debes comprobar especialmente:

- que exista `pedido_id`
- que exista `producto_id`
- que las claves dimensionales apunten a las dimensiones correctas
- que las medidas comerciales esten calculadas:
  - `cantidad_vendida`
  - `venta_bruta`
  - `descuento_total`
  - `venta_neta`
  - `costo_total`
  - `margen_bruto`
  - `pct_margen_bruto`
- que los tiempos operativos también esten presentes:
  - `minutos_confirmacion`
  - `minutos_despacho`
  - `horas_entrega`
  - `horas_lead_time`

## 9. Grano y claves del hecho actual

`fact_ventas` se construyo con este grano:

- una fila por línea de pedido por producto

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
- captura de `dbt run --select +marts`
- captura de `marts.fact_ventas` consultada en PostgreSQL

## 11. Cierre

En esta sesión queda validado que:

- `staging` se construye por tabla fuente del OLTP
- `marts` implementa la estrella final del caso
- `fact_ventas` integra cabecera, detalle y dimensiones
- el DataMart físico base queda listo para validación analítica
