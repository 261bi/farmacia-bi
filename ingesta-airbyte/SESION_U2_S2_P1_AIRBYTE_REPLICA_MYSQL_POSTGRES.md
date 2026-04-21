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
- `sync`: ejecucion de replica
- `full refresh`: copia completa de datos desde el origen
- `raw`: capa inicial donde aterrizan los datos antes de las transformaciones analiticas

### 6.1 Donde encaja CDC en esta sesion

En una arquitectura moderna, `CDC` pertenece a la fase de ingesta.

En esta sesion:

- Airbyte trabaja sobre la captura y replica desde el OLTP
- por eso, conceptualmente, `CDC` ocurre aqui
- en esta primera version del laboratorio se usa `Full refresh | Overwrite`
- eso significa que todavia no se implementa CDC real basado en logs

Importante:

- `farmadb` si es una fuente OLTP valida para una estrategia de CDC
- pero CDC en MySQL requiere configuracion adicional del motor y del conector

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

Configuracion recomendada:

- modo por tabla: `Full refresh | Overwrite`
- frecuencia: `Manual` o `Every 24 hours`

### 8.8 Ejecuta la primera sincronizacion

Desde la conexion creada, ejecuta:

- `Sync now`

Resultado esperado:

- la sincronizacion termina en estado `Succeeded`

### 8.9 Valida que Airbyte cargo datos en `raw`

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
