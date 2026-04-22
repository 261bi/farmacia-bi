# Sesion U2 S2 P1: Airbyte para replica batch MySQL a PostgreSQL

## 1. Titulo

Implementacion de una replica batch desde MySQL hacia PostgreSQL usando Airbyte como herramienta de ingesta de datos.

## 2. Objetivo

Configurar y validar una replica inicial desde la base transaccional `farmadb` en MySQL hacia la capa `raw` de la base `farmacia_dw` en PostgreSQL, usando Airbyte local.

Al finalizar la sesion, el alumno debe poder:

- levantar el origen MySQL y el destino PostgreSQL
- acceder a Airbyte local
- crear un source MySQL desde cero
- crear un destination PostgreSQL desde cero
- construir una conexion de replica
- ejecutar una sincronizacion manual
- validar que los datos llegaron correctamente al schema `raw`

## 3. Herramientas utilizadas

- Docker Compose
- MySQL 8.4
- PostgreSQL 16
- Airbyte local
- PowerShell
- Navegador web

## 4. Entorno de trabajo

Trabaja sobre el proyecto `farmacia-bi` usando:

- MySQL fuente: `localhost:13306`
- PostgreSQL destino: `localhost:15432`
- Base fuente MySQL: `farmadb`
- Base destino PostgreSQL: `farmacia_dw`
- Schema de aterrizaje: `raw`
- Airbyte local: `http://localhost:8010`

Credenciales del entorno:

- MySQL
  - usuario: `root`
  - contrasena: `root`
- PostgreSQL
  - usuario: `postgres`
  - contrasena: `postgres`

## 5. Flujo de la practica

```text
MySQL (farmadb) -> Airbyte -> PostgreSQL (farmacia_dw.raw)
```

## 6. Fundamento teorico breve

- `source`: origen de datos que Airbyte lee
- `destination`: destino donde Airbyte escribe los datos
- `connection`: vinculo entre source y destination con su configuracion de sincronizacion
- `sync`: ejecucion de replica entre el origen y el destino
- `cursor`: columna que permite detectar registros nuevos o modificados para sincronizaciones incrementales
- `full refresh`: recarga completa de los datos desde el origen
- `incremental`: carga solo registros nuevos o modificados desde el origen, normalmente usando un `cursor`
- `CDC`: captura cambios en la fuente, como `insert`, `update` y `delete`
- `raw`: capa inicial donde aterrizan los datos antes de las transformaciones analiticas

En esta practica, lo que corresponde aplicar es:

- replica desde MySQL hacia PostgreSQL
- aterrizaje en `raw`
- configuracion de `cursor`
- sincronizacion incremental cuando el conector lo permita de forma estable

En cambio, `CDC` se deja ubicado aqui como concepto de ingesta moderna, pero no se implementa en esta primera practica como captura basada en logs del motor.

### 6.1 Donde encaja CDC (Change Data Capture) en esta sesion

En una arquitectura moderna, `CDC` pertenece a la fase de ingesta.

En esta sesion:

- Airbyte trabaja sobre la captura y replica desde el OLTP
- por eso, conceptualmente, `CDC` ocurre aqui
- como el `farmadb` actual ya incluye `fecha_creacion` y `fecha_modificacion`, ahora si existe una base minima para trabajar sincronizacion incremental con `cursor`
- eso no significa todavia CDC real basado en logs
- pero si permite una replica incremental mas cercana a cambios recientes en las tablas

Importante:

- `farmadb` si es una fuente OLTP valida para una estrategia de CDC
- pero CDC en MySQL requiere configuracion adicional del motor y del conector
- en esta practica, el uso de `cursor` se apoya en columnas temporales del modelo y no en binlog de MySQL

## 7. Mapa actual del OLTP `farmadb`

Esta practica usa el esquema renombrado actual definido en:

- [farmadb.sql](../oltp-mysql/mysql/init/farmadb.sql)

Tablas fuente relevantes:

- `clientes`
- `vendedores`
- `familias`
- `categorias`
- `productos`
- `pedidos`
- `pedido_detalles`

Campos clave del modelo actual:

- `clientes`: `id`, `nombre`
- `vendedores`: `id`, `nombre`
- `familias`: `id`, `nombre`
- `categorias`: `id`, `nombre`, `familia_id`
- `productos`: `id`, `codigo`, `nombre`, `concentracion`, `presentacion`, `fracciones`, `precio_compra`, `precio_venta`, `categoria_id`
- `pedidos`: `id`, `fecha_creacion`, `fecha_confirmacion`, `fecha_envio`, `fecha_entrega`, `fecha_pago`, `estado`, `cliente_id`, `direccion`, `vendedor_id`
- `pedido_detalles`: `pedido_id`, `producto_id`, `cantidad`, `precio_compra_unitario`, `precio_venta_unitario`, `total_descuento_unitario`, `igv_unitario`

Campos utiles para incremental:

- `fecha_modificacion`: cursor recomendado cuando la tabla lo tenga
- `fecha_creacion`: cursor alternativo para una primera aproximacion

## 8. Desarrollo de la practica

### 8.1 Levanta el OLTP MySQL

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

### 8.2 Levanta el PostgreSQL del DW

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose up -d
docker compose ps
```

### 8.3 Verifica que PostgreSQL tenga los schemas del DW

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego:

```sql
\dn
```

Debes ver:

- `raw`
- `staging`
- `marts`

### 8.4 Verifica acceso a Airbyte

Abre en el navegador:

```text
http://localhost:8010
```

### 8.5 Crea el source MySQL

- Source name: `mysql-farmadb`
- Host: `host.docker.internal`
- Port: `13306`
- Database: `farmadb`
- Username: `root`
- Password: `root`

### 8.6 Crea el destination PostgreSQL

- Destination name: `postgres-farmacia-raw`
- Host: `host.docker.internal`
- Port: `15432`
- Database: `farmacia_dw`
- Schema: `raw`
- Username: `postgres`
- Password: `postgres`

### 8.7 Crea la conexion de replica

Trabaja con estas tablas:

- `categorias`
- `clientes`
- `familias`
- `pedido_detalles`
- `pedidos`
- `productos`
- `vendedores`

En la pantalla `Select sync mode`, elige:

- `Replicate Source`

Interpretacion:

- esta opcion mantiene una copia actualizada de la fuente en el destino
- para esta practica no se busca guardar historial completo de cambios en la capa `raw`
- por eso no se elige `Append Historical Changes`

Configuracion recomendada de streams:

- modo por tabla: `Incremental | Append + Deduped`
- cursor recomendado: `fecha_modificacion`
- cursor alternativo: `fecha_creacion`
- primary key:
  - `id` para `clientes`, `vendedores`, `familias`, `categorias`, `productos`, `pedidos`
  - `pedido_id, producto_id` para `pedido_detalles` si el conector permite clave compuesta; si no, documenta la limitacion y usa validacion posterior
- frecuencia: `Manual` o `Every 24 hours`

Observacion didactica:

- si alguna tabla o configuracion puntual del conector no se deja resolver bien en incremental, puedes usar `Full refresh | Overwrite` como respaldo
- pero con el `farmadb` actual, la explicacion base ya debe presentar el uso de `cursor`

### 8.8 Configura cada stream paso a paso

En la lista de tablas, configura cada una asi:

- `categorias`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `clientes`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `familias`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `pedidos`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `productos`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `vendedores`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `id`
  - cursor: `fecha_modificacion`
- `pedido_detalles`
  - sync mode: `Incremental | Append + Deduped`
  - primary key: `pedido_id`, `producto_id`
  - cursor: `fecha_modificacion`

Importante:

- en Airbyte, la `primary key` y el `cursor` no son lo mismo
- la `primary key` sirve para deduplicar
- el `cursor` sirve para detectar registros nuevos o modificados
- por eso es normal que `id` quede fijo como `primary key` y que el campo que si cambias sea `fecha_modificacion`

### 8.9 Configura la conexion

En la pantalla `Configure connection`, usa:

- Connection name: `mysql-farmadb -> postgres-farmacia-raw`
- Schedule type: `Manual`
- Destination Namespace: `Destination-defined`
- Stream Prefix: vacio

Interpretacion:

- `Manual` es mejor para laboratorio porque el estudiante controla cuando sincronizar
- `Destination-defined` mantiene el schema `raw` definido en el destination
- el prefijo se deja vacio para no alterar los nombres de las tablas aterrizadas

### 8.10 Revisa la configuracion avanzada

En `Advanced settings`, deja:

- `Propagate field changes only`
- `Be notified when schema changes occur`: activado
- `Backfill new or renamed columns`: apagado

Interpretacion:

- `Propagate field changes only`
  - Airbyte propaga cambios compatibles de columnas
  - evita una automatizacion excesiva sobre tablas o streams completos
- `Be notified when schema changes occur`
  - Airbyte avisa si el esquema de la fuente cambia
- `Backfill new or renamed columns`
  - se deja apagado para no complicar la practica con recargas historicas adicionales

Con esto, la practica queda estable y controlable para clase.

### 8.11 Ejecuta la primera sincronizacion

Desde la conexion creada, ejecuta:

- `Sync now`

Resultado esperado:

- la sincronizacion termina en estado `Succeeded`

### 8.12 Valida que Airbyte cargo datos en `raw`

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego:

```sql
\dt raw.*
SELECT * FROM raw.categorias LIMIT 10;
SELECT * FROM raw.productos LIMIT 10;
SELECT * FROM raw.pedidos LIMIT 10;
SELECT * FROM raw.pedido_detalles LIMIT 10;
```

## 9. Evidencias a entregar

- captura de `docker compose ps` de `oltp-mysql`
- captura de `docker compose ps` de `dw-pg`
- captura de Airbyte con el source MySQL configurado
- captura de Airbyte con el destination PostgreSQL configurado
- captura del job de sincronizacion en estado exitoso
- captura de PostgreSQL mostrando tablas en `raw`

## 10. Cierre

Si la practica salio correctamente, debes haber validado el flujo base de integracion:

```text
MySQL (farmadb) -> Airbyte -> PostgreSQL (farmacia_dw.raw)
```
