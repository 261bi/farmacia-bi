# Sesión U2 S1 P2: dbt para modelado físico del DataMart

## 1. Título

Preparación del entorno `dbt` en Docker para implementar el modelado físico del DataMart sobre PostgreSQL.

## 2. Objetivo

Levanta y valida un entorno base con `dbt` para continuar el proceso de construcción del `Data Warehouse` y del `DataMart`, usando como entrada la capa `raw` cargada previamente por Airbyte.

Al finalizar la sesión, el alumno debe poder:

- levantar el contenedor de `dbt`
- acceder al contenedor
- verificar la instalación de `dbt-core` y `dbt-postgres`
- comprender el papel de `dbt` en la arquitectura analítica
- construir la capa `staging`
- construir dimensiones y el hecho principal del `DataMart`

## 3. Herramientas utilizadas

- Docker Compose
- Docker
- dbt Core
- dbt Postgres
- PostgreSQL
- PowerShell

## 4. Entorno de trabajo

Trabaja sobre el proyecto `farmacia-bi` usando:

- carpeta de trabajo `dw-dbt`: `C:\261bi\farmacia-bi\dw-dbt`
- contenedor: `farmacia-dw-dbt`
- motor analítico de trabajo: PostgreSQL
- fuente de datos transformables: capa `raw` previamente cargada por Airbyte

## 5. Flujo de arquitectura

Usa este flujo como referencia:

```text
MySQL -> Airbyte -> PostgreSQL raw -> dbt staging -> dbt marts
```

Interpreta cada componente así:

- `MySQL`: origen operacional
- `Airbyte`: replica datos hacia PostgreSQL
- `PostgreSQL raw`: aterrizaje inicial de datos
- `dbt staging`: limpieza, estandarización y tipado
- `dbt marts`: tablas analíticas finales para consultas y reportes

## 6. Fundamento teórico breve

Ten presentes estos conceptos:

- `dbt`: herramienta de transformación basada en SQL y versionada en archivos
- `model`: consulta SQL administrada por `dbt`
- `materialization`: forma en que el modelo se crea en la base, por ejemplo `view` o `table`
- `staging`: capa de limpieza y estandarización
- `mart`: capa orientada al análisis de negocio

### 6.1 Diferencia entre `raw`, `staging` y `marts`

En este proyecto debes distinguir claramente tres capas:

- `raw`
  - contiene tablas aterrizadas por Airbyte
  - conserva la estructura del origen transaccional
  - puede incluir columnas técnicas como `_airbyte_*`
- `staging`
  - se construye por tabla fuente relevante del OLTP
  - sirve para limpiar, tipar, renombrar y estandarizar datos
  - todavía no representa el modelo dimensional final
- `marts`
  - contiene dimensiones y hechos
  - implementa el modelo estrella final para análisis y reportes

Regla práctica:

- `staging` se hace primero por tabla transaccional o tabla fuente relevante
- `marts` se hace después por dimensión y hecho del modelo analítico

### 6.2 Aplicación al caso `farmadb`

Tablas fuente relevantes del OLTP:

- `clientes`
- `vendedores`
- `familias`
- `categorias`
- `productos`
- `pedidos`
- `pedido_detalles`

Por eso, la capa `staging` del proyecto debe organizarse inicialmente con modelos como:

- `stg_clientes`
- `stg_vendedores`
- `stg_familias`
- `stg_categorias`
- `stg_productos`
- `stg_pedidos`
- `stg_pedido_detalles`

Luego, a partir de esos `stg_*`, se construyen los `marts`.

### 6.3 Modelo estrella final del caso

El modelo dimensional final del curso se trabajará como estrella.

Dimensiones finales:

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`

Hecho principal:

- `fact_ventas`

Importante:

- `dim_producto` será una dimensión denormalizada
- `categoría` y `familia` no quedarán como dimensiones separadas
- sus atributos quedarán dentro de `dim_producto`

Mapa simplificado de dependencia:

```text
stg_clientes ---------> dim_cliente
stg_vendedores -------> dim_vendedor
stg_familias --\
stg_categorias -+-----> dim_producto
stg_productos --/
stg_pedidos -----------\
stg_pedido_detalles ----+-----> fact_ventas
dim_fecha -------------/
dim_estado_pedido -----/
```

### 6.4 Estrategia de construcción en dbt

Antes, este tipo de solución podía construirse con:

- una vista integrada intermedia
- joins posteriores a dimensiones
- e inserción final en una tabla de hechos

En `dbt`, la misma lógica se organiza por capas:

1. `staging`
   - prepara cada tabla fuente relevante
2. `dimensions`
   - resuelve dimensiones del modelo estrella
3. `fact`
   - integra detalle, cabecera y dimensiones
   - calcula medidas comerciales y operativas

En este proyecto, la estrategia aplicada fue:

- `stg_pedidos` para la cabecera del pedido
- `stg_pedido_detalles` para el detalle del pedido
- `stg_clientes`, `stg_vendedores`, `stg_familias`, `stg_categorias`, `stg_productos` para el resto del contexto
- `dim_producto` como dimensión denormalizada con producto, categoría y familia
- `fact_ventas` como hecho al grano: una fila por línea de pedido por producto

## 7. Desarrollo de la práctica

### 7.1 Ubícate en el directorio de dbt

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
```

Verifica archivos:

```powershell
Get-ChildItem
```

Debes tener al menos:

- `Dockerfile`
- `docker-compose.yml`
- `README.md`

### 7.2 Construye y levanta el contenedor

Ejecuta:

```powershell
docker compose down
docker compose up -d --build
```

Esto debe:

- construir la imagen de `dbt`
- instalar `dbt-core`
- instalar `dbt-postgres`
- instalar `git`, requerido por `dbt`
- dejar el contenedor disponible para trabajo interactivo

### 7.3 Verifica el estado del servicio

Ejecuta:

```powershell
docker compose ps
```

Resultado esperado:

- el servicio `dbt` aparece en estado `Up`

### 7.4 Ingresa al contenedor

Ejecuta:

```powershell
docker exec -it farmacia-dw-dbt bash
```

Una vez dentro, ubícate en:

```bash
cd /usr/app/farmacia_bi
```

### 7.5 Verifica la instalación de dbt

Dentro del contenedor, ejecuta:

```bash
dbt --version
```

Debes verificar que estén disponibles:

- `dbt-core`
- `dbt-postgres`

### 7.6 Crea manualmente la estructura del proyecto

Dentro del contenedor, ubícate en:

```bash
cd /usr/app
```

Crea la estructura base:

```bash
mkdir -p farmacia_bi/models/staging
mkdir -p farmacia_bi/models/marts
mkdir -p farmacia_bi/models/intermediate
mkdir -p farmacia_bi/seeds
mkdir -p farmacia_bi/tests
mkdir -p /root/.dbt
```

Ingresa al directorio del proyecto:

```bash
cd /usr/app/farmacia_bi
```

### 7.7 Crea el archivo `dbt_project.yml`

Crea el archivo:

```bash
touch dbt_project.yml
```

Ábrelo con el editor disponible en tu entorno o créalo desde consola con este contenido:

```yaml
name: 'farmacia_bi'
version: '1.0.0'
config-version: 2

profile: 'farmacia_bi'

model-paths: ['models']
seed-paths: ['seeds']
test-paths: ['tests']

clean-targets:
  - 'target'
  - 'dbt_packages'

models:
  farmacia_bi:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
```

### 7.8 Crea el archivo `profiles.yml`

Crea el archivo:

```bash
touch /root/.dbt/profiles.yml
```

Usa este contenido:

```yaml
farmacia_bi:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres-farmacia-raw
      user: postgres
      password: postgres
      port: 5432
      dbname: farmacia_raw
      schema: public
      threads: 1
```

Notas importantes:

- `dbt` y PostgreSQL deben estar en la misma red Docker para usar el nombre del contenedor como host
- `postgres-farmacia-raw` es el nombre del contenedor de PostgreSQL dentro de la red compartida
- `schema: public` indica dónde se crearán inicialmente los modelos transformados

### 7.9 Verifica la conexión con `dbt debug`

Desde `/usr/app/farmacia_bi`, ejecuta:

```bash
dbt debug
```

Resultado esperado:

- `profiles.yml file [OK found and valid]`
- `dbt_project.yml file [OK found and valid]`
- `git [OK found]`
- `Connection test: [OK connection ok]`

### 7.10 Crea el primer modelo de staging

Crea un archivo llamado:

```bash
touch models/staging/stg_categorias.sql
```

Usa este contenido:

```sql
select
    id,
    nombre,
    familia_id
from public.categorias
```

### 7.11 Ejecuta el primer modelo

Desde la raíz del proyecto, ejecuta:

```bash
dbt run --select stg_categorias
```

Resultado esperado:

- dbt crea el modelo `stg_categorias`
- el modelo queda materializado como `view`
- la ejecución termina en estado exitoso

Resultado observado en esta práctica:

- `dbt` creó `public.stg_categorias`
- el objeto fue creado como `sql view model`
- la ejecución terminó con:
  - `PASS=1`
  - `WARN=0`
  - `ERROR=0`

Durante la ejecución puede aparecer este mensaje:

```text
Configuration paths exist in your dbt_project.yml file which do not apply to any resources
```

Interpretación:

- no es un error bloqueante
- aparece porque las carpetas `models/intermediate` y `models/marts` todavía no tienen modelos `.sql` creados
- puedes continuar normalmente con la práctica

### 7.12 Valida el resultado en PostgreSQL

Desde PowerShell, fuera del contenedor `dbt`, ejecuta:

```powershell
docker exec -it postgres-farmacia-raw psql -U postgres -d farmacia_raw
```

Luego valida:

```sql
\dv
SELECT * FROM stg_categorias LIMIT 10;
```

Resultado esperado:

- la vista `stg_categorias` aparece dentro de `Views`
- la vista contiene las columnas:
  - `id`
  - `nombre`
  - `familia_id`

### 7.13 Construye toda la capa `staging`

Una vez validado el primer modelo, ejecuta toda la carpeta `staging`:

```bash
dbt run --select staging
```

Modelos esperados:

- `stg_clientes`
- `stg_vendedores`
- `stg_familias`
- `stg_categorias`
- `stg_productos`
- `stg_pedidos`
- `stg_pedido_detalles`

Resultado esperado:

- todos los modelos `stg_*` se crean como `view`

### 7.14 Construye las dimensiones del DataMart

Ejecuta:

```bash
dbt run --select +marts
```

Dimensiones construidas en esta práctica:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`

Notas importantes:

- `dim_cliente` y `dim_vendedor` conservan la clave de negocio del OLTP para trazabilidad
- `dim_producto` queda denormalizada e incluye datos de producto, categoría y familia
- `dim_fecha` usa inicialmente `fecha_creacion` como fecha analítica principal
- `dim_estado_pedido` toma los estados distintos del pedido

### 7.15 Construye el hecho principal `fact_ventas`

Ejecuta:

```bash
dbt run --select +fact_ventas
```

`fact_ventas` se construyó con este grano:

- una fila por línea de pedido por producto

Claves dimensionales utilizadas:

- `fecha_key`
- `cliente_key`
- `vendedor_key`
- `producto_key`
- `estado_pedido_key`

Campos de trazabilidad conservados:

- `pedido_id`
- `producto_id`

Medidas calculadas:

- `cantidad_vendida`
- `venta_bruta`
- `descuento_total`
- `venta_neta`
- `costo_total`
- `margen_bruto`
- `pct_margen_bruto`
- `minutos_confirmacion`
- `minutos_despacho`
- `horas_entrega`
- `horas_lead_time`
- `pedido_count`

### 7.16 Valida la estrella final en PostgreSQL

Desde PostgreSQL, verifica:

```sql
\dt
SELECT * FROM dim_cliente LIMIT 10;
SELECT * FROM dim_vendedor LIMIT 10;
SELECT * FROM dim_producto LIMIT 10;
SELECT * FROM dim_fecha LIMIT 10;
SELECT * FROM dim_estado_pedido LIMIT 10;
SELECT * FROM fact_ventas LIMIT 20;
```

Resultado esperado:

- el esquema `public` contiene dimensiones y hecho
- `fact_ventas` ya puede usarse como base para Power BI

### 7.17 Relaciona dbt con el diseño físico del DW

En esta fase, `dbt` no reemplaza PostgreSQL.
Su rol es construir, mediante SQL versionado, las tablas y vistas analíticas sobre la base de datos.

Interprétalo así:

- PostgreSQL almacena físicamente los datos
- Airbyte carga la capa `raw`
- dbt transforma esa capa primero en `staging` y luego en `marts`

Ejemplos de modelos que se podrían construir en las siguientes sesiones:

- `stg_clientes`
- `stg_vendedores`
- `stg_familias`
- `stg_categorias`
- `stg_productos`
- `stg_pedidos`
- `stg_pedido_detalles`
- `dim_cliente`
- `dim_producto`
- `dim_vendedor`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

## 8. Qué debe observar el alumno

Durante esta práctica, observa y registra:

- si la imagen se construye correctamente
- si el contenedor `dbt` queda en ejecución
- si `dbt --version` responde correctamente
- si `dbt debug` valida correctamente el proyecto y la conexión
- si `stg_categorias` se crea correctamente en PostgreSQL
- si `stg_categorias` aparece como vista y no como tabla
- si toda la capa `staging` se crea correctamente
- si las dimensiones se crean como tablas
- si `fact_ventas` queda cargada con el grano correcto
- qué rol cumple `dbt` dentro del flujo de datos
- cómo se separa la capa `raw` de la capa de transformación

## 9. Problemas comunes

### Caso 1. Falla el build por archivos faltantes

Verifica que en `dbt/` existan:

- `Dockerfile`
- `docker-compose.yml`

### Caso 2. El contenedor se detiene al iniciar

Verifica que `docker-compose.yml` use un comando persistente como:

```text
sleep infinity
```

### Caso 3. `dbt --version` no responde

Verifica que la imagen se haya construido de nuevo con:

```powershell
docker compose up -d --build
```

### Caso 4. `dbt debug` no conecta con PostgreSQL

Verifica:

- que PostgreSQL siga levantado
- que `dbt` y PostgreSQL estén en la misma red Docker
- que el host sea `postgres-farmacia-raw`
- que el puerto usado sea `5432`
- que las credenciales sean:
  - usuario `postgres`
  - contraseña `postgres`

### Caso 5. El modelo no encuentra la tabla `categorias`

Verifica que Airbyte ya haya replicado la tabla en PostgreSQL y confirma su existencia con:

```sql
\dt
```

### Caso 6. Aparece una advertencia sobre `models.marts` o `models.intermediate`

Si aparece una advertencia sobre rutas configuradas que todavía no aplican a recursos:

- no es un error
- significa que esas carpetas existen en `dbt_project.yml`
- pero aún no contienen modelos `.sql`

### Caso 7. `fact_ventas` no carga correctamente

Verifica:

- que `stg_pedidos` y `stg_pedido_detalles` existan
- que `dim_cliente`, `dim_vendedor`, `dim_producto`, `dim_fecha` y `dim_estado_pedido` estén creadas
- que las claves de negocio usadas en los joins coincidan con los datos del OLTP replicado

## 10. Evidencias a entregar

Adjunta como evidencia:

- captura de `docker compose ps`
- captura de ingreso al contenedor `dbt`
- captura de la salida de `dbt --version`
- captura de `dbt debug` exitoso
- captura de `dbt run --select stg_categorias`
- captura de la vista `stg_categorias` consultada en PostgreSQL
- captura del árbol de PostgreSQL mostrando `stg_categorias` dentro de `Views`
- captura de `dbt run --select staging`
- captura de `dbt run --select +marts`
- captura de `dbt run --select +fact_ventas`
- captura de `fact_ventas` consultada en PostgreSQL
- breve explicación del flujo `raw -> staging -> marts`

## 11. Actividad de aprendizaje autónomo

Propón la estructura inicial del proyecto `dbt` para este caso de farmacia e indica:

- qué modelos pondrías en `staging`
- qué dimensiones construirías
- qué hechos propondrías
- qué materializaciones usarías inicialmente

## 12. Cierre

Si la práctica salió correctamente, debes haber dejado listo el entorno técnico para continuar con el modelado físico del `DataMart` usando `dbt` sobre PostgreSQL.

En esta sesión quedó validado, paso a paso, que:

- `dbt` se ejecuta dentro de Docker
- el proyecto `farmacia_bi` está correctamente configurado
- `dbt debug` valida la conexión con PostgreSQL
- el primer modelo `stg_categorias` se crea como vista en la base `farmacia_raw`
- la capa `staging` se construye por tabla fuente del OLTP
- las dimensiones del modelo estrella se construyen en `marts`
- `fact_ventas` integra cabecera, detalle y dimensiones
- el DataMart físico base queda listo para explotación en Power BI
