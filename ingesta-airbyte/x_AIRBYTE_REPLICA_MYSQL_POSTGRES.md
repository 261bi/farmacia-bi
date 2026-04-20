# Sesión U2 S1 P2: Airbyte para réplica batch MySQL a PostgreSQL

## 1. Título

Implementación de una réplica batch desde MySQL hacia PostgreSQL usando Airbyte como herramienta de ingesta de datos.

## 2. Objetivo

Configurar y validar una réplica inicial desde la base transaccional `farmadb` en MySQL hacia la capa `raw` de la base `farmacia_dw` en PostgreSQL, usando Airbyte local.

Al finalizar la sesión, el alumno debe poder:

- levantar el origen MySQL y el destino PostgreSQL
- acceder a Airbyte local
- crear un source MySQL desde cero
- crear un destination PostgreSQL desde cero
- construir una conexión de réplica
- ejecutar una sincronización manual
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
  - contraseña: `root`
- PostgreSQL
  - usuario: `postgres`
  - contraseña: `postgres`

## 5. Flujo de la práctica

Usa este flujo de integración:

```text
MySQL (farmadb) -> Airbyte -> PostgreSQL (farmacia_dw.raw)
```

Interpreta cada componente así:

- `MySQL`: sistema fuente con datos operacionales
- `Airbyte`: extrae datos del source y los replica al destino
- `PostgreSQL`: aloja la capa `raw` donde aterrizan los datos replicados

## 6. Fundamento teórico breve

Ten presentes estos conceptos:

- `source`: origen de datos que Airbyte lee
- `destination`: destino donde Airbyte escribe los datos
- `connection`: vínculo entre source y destination con su configuración de sincronización
- `sync`: ejecución de réplica
- `full refresh`: copia completa de datos desde el origen
- `raw`: capa inicial donde aterrizan los datos antes de las transformaciones analíticas

## 7. Desarrollo de la práctica

### 7.1 Levanta el OLTP MySQL

Ubícate en:

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
```

Levanta el servicio:

```powershell
docker compose up -d
docker compose ps
```

Resultado esperado:

- contenedor `farmacia-oltp-mysql` en estado `Up`

### 7.2 Levanta el PostgreSQL del DW

Ubícate en:

```powershell
cd C:\261bi\farmacia-bi\dw-pg
```

Levanta el servicio:

```powershell
docker compose up -d
docker compose ps
```

Resultado esperado:

- contenedor `farmacia-dw-pg` en estado `Up`

### 7.3 Verifica que PostgreSQL tenga los schemas del DW

Ejecuta:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Dentro de PostgreSQL:

```sql
\dn
```

Debes ver al menos:

- `raw`
- `staging`
- `marts`

Si ya verificaste, sal con:

```sql
\q
```

### 7.4 Verifica acceso a Airbyte

Abre en el navegador:

```text
http://localhost:8010
```

Si es la primera vez que entras, completa la pantalla inicial de preferencias:

- correo
- nombre de organización
- telemetría opcional

Debes llegar al panel principal de Airbyte.

### 7.5 Si existe una conexión previa, elimínala para reiniciar la práctica

Esta sesión está pensada como una guía desde cero para estudiantes. Por eso, si ya existe una conexión anterior creada en Airbyte, elimínala antes de empezar de nuevo.

Recomendación:

- revisa `Connections`
- si ya existe una conexión previa del laboratorio, elimínala
- si ya existe también el source o el destination y quieres rehacer toda la práctica exactamente desde cero, elimínalos también

La idea de esta sesión es que el alumno construya manualmente:

- el `source`
- el `destination`
- la `connection`

### 7.6 Crea el source MySQL

En Airbyte, crea un nuevo source de tipo `MySQL`.

Usa estos valores:

- Source name: `mysql-farmadb`
- Host: `host.docker.internal`
- Port: `13306`
- Database: `farmadb`
- Username: `root`
- Password: `root`

Notas importantes:

- si Airbyte se ejecuta dentro de contenedores locales, `localhost` puede no funcionar desde los componentes internos
- en Windows con Docker Desktop, usa `host.docker.internal` para que Airbyte alcance servicios expuestos en la máquina host

Haz clic en:

- `Set up source`

Resultado esperado:

- conexión exitosa al source MySQL

### 7.7 Crea el destination PostgreSQL

En Airbyte, crea un nuevo destination de tipo `Postgres`.

Usa estos valores:

- Destination name: `postgres-farmacia-raw`
- Host: `host.docker.internal`
- Port: `15432`
- Database: `farmacia_dw`
- Schema: `raw`
- Username: `postgres`
- Password: `postgres`

Haz clic en:

- `Set up destination`

Resultado esperado:

- conexión exitosa al destino PostgreSQL

### 7.8 Crea la conexión de réplica

Construye una nueva conexión entre:

- source: `mysql-farmadb`
- destination: `postgres-farmacia-raw`

En la pantalla de selección de transmisiones, trabaja con estas tablas:

- `categorias`
- `clientes`
- `familias`
- `pedido_detalles`
- `pedidos`
- `productos`
- `vendedores`

En esta práctica, usa exactamente esta configuración:

- activa las tablas detectadas de `farmadb`
- para cada tabla, cambia el modo de sincronización a:
  - `Full refresh | Overwrite`
- no uses modo incremental en esta primera sesión

Razón de esta decisión:

- Airbyte solicita un `cursor` para el modo incremental
- en este esquema, originalmente las tablas no tenían una columna sólida de control de cambios para usar como cursor funcional de clase
- para validar primero la réplica base, se trabaja con `Full refresh | Overwrite`

En la configuración general de la conexión, usa:

- Replication frequency: `Manual` o `Every 24 hours`, según indique el docente

### 7.9 Ejecuta la primera sincronización

Desde la conexión creada, ejecuta:

- `Sync now`

Observa en Airbyte:

- inicio del job
- tablas seleccionadas
- registros leídos
- registros escritos
- estado final del job

Resultado esperado:

- la sincronización debe terminar en estado `Succeeded`

### 7.10 Valida que Airbyte cargó datos en `raw`

Ahora sí valida en PostgreSQL que la réplica realmente llegó al schema `raw`.

Ejecuta:

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

Debes comprobar:

- que las tablas existan en el schema `raw`
- que tengan registros
- que Airbyte haya creado la estructura de aterrizaje correctamente

### 7.11 Interpreta las columnas técnicas agregadas por Airbyte

Al consultar tablas replicadas en PostgreSQL, verás columnas adicionales que no existían en MySQL.

Ejemplo:

- `_airbyte_raw_id`
- `_airbyte_extracted_at`
- `_airbyte_meta`
- `_airbyte_generation_id`

Estas columnas no son parte del modelo del negocio. Airbyte las agrega para trazabilidad técnica.

Interpreta cada una así:

- `_airbyte_raw_id`
  - identificador técnico único de la fila replicada
- `_airbyte_extracted_at`
  - fecha y hora en que Airbyte extrajo el registro desde MySQL
- `_airbyte_meta`
  - campo JSON con metadatos del proceso de sincronización
- `_airbyte_generation_id`
  - identificador interno de la generación o versión de carga

Las columnas del negocio siguen siendo, por ejemplo:

- `id`
- `nombre`

Interpretación práctica:

- las columnas `_airbyte_*` sirven para auditoría y control del pipeline
- las columnas funcionales del negocio son las que vienen del source original
- en la capa `raw`, es normal conservar ambas

## 8. Qué debe observar el alumno

Durante la práctica, observa y registra:

- si Airbyte conecta correctamente con MySQL
- si Airbyte conecta correctamente con PostgreSQL
- si la sincronización termina sin errores
- qué tablas fueron seleccionadas
- cuántos registros fueron replicados
- qué diferencias hay entre la estructura del source y la tabla aterrizada en `raw`

## 9. Problemas comunes

### Caso 1. Airbyte no conecta a MySQL o PostgreSQL usando `localhost`

Prueba con:

```text
host.docker.internal
```

### Caso 2. El puerto ya está ocupado

Verifica que los servicios expongan:

- MySQL en `13306`
- PostgreSQL en `15432`
- Airbyte en `8010`

### Caso 3. Airbyte tarda bastante en iniciar

Esto es normal en la primera ejecución porque:

- descarga imágenes
- crea el entorno local
- inicializa componentes internos

### Caso 4. La conexión anterior confunde la práctica

Si ya existe una conexión previa:

- elimínala
- vuelve a crear source, destination y connection siguiendo esta sesión

Así garantizas que el laboratorio realmente se ejecuta paso a paso.

## 10. Evidencias a entregar

Adjunta como evidencia:

- captura de `docker compose ps` de `oltp-mysql`
- captura de `docker compose ps` de `dw-pg`
- captura de Airbyte con el source MySQL configurado
- captura de Airbyte con el destination PostgreSQL configurado
- captura del job de sincronización en estado exitoso
- captura de PostgreSQL mostrando tablas en `raw`
- captura de una consulta con registros replicados

## 11. Actividad de aprendizaje autónomo

A partir de la conexión creada, documenta:

- qué tablas replicaste
- qué modo de sincronización usaste
- qué ventajas y desventajas tiene `Full refresh`
- por qué en esta práctica no se trabajó incremental
- qué cambiarías para una segunda versión incremental
- qué transformaciones aplicarías luego en una capa analítica con dbt

## 12. Cierre

Si la práctica salió correctamente, debes haber validado el flujo base de integración batch:

```text
MySQL (farmadb) -> Airbyte -> PostgreSQL (farmacia_dw.raw)
```

y dejado lista la capa `raw` para la siguiente etapa del laboratorio:

```text
raw -> staging -> marts -> Power BI
```
