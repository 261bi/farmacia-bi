# Ingesta Airbyte

Esta carpeta queda reservada para la configuración y documentación de la ingesta con Airbyte.

## Rol en la arquitectura

```text
MySQL (oltp-mysql) -> Airbyte -> PostgreSQL (dw-pg.raw)
```

## Destino recomendado en Airbyte

- Host: `host.docker.internal`
- Port: `15432`
- Database: `farmacia_dw`
- Schema: `raw`
- User: `postgres`
- Password: `postgres`

## Nota

La instalación local de Airbyte se trabaja por separado con `abctl`.


## Levantar el entorno

### Levantar MySQL OLTP

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
```

### Levantar PostgreSQL DW

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose up -d
```

## Verificar contenedores

### Verificar MySQL OLTP

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose ps
```

### Verificar PostgreSQL DW

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose ps
```

## Accesos esperados

- MySQL OLTP: `localhost:13306`
- PostgreSQL DW: `localhost:15432`

## Contenedores

- MySQL: `farmacia-oltp-mysql`
- PostgreSQL: `farmacia-dw-pg`

## Credenciales

### MySQL

- Host: `localhost`
- Port: `13306`
- Database: `farmadb`
- User: `root`
- Password: `root`

### PostgreSQL

- Host: `localhost`
- Port: `15432`
- Database: `farmacia_dw`
- User: `postgres`
- Password: `postgres`

## Esquemas de PostgreSQL

La base `farmacia_dw` queda separada lógicamente en:

- `raw`: aterrizaje inicial desde Airbyte
- `staging`: vistas y modelos intermedios de dbt
- `marts`: dimensiones y hechos finales del DataMart

Puedes validarlo con:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Y dentro de PostgreSQL:

```sql
\dn
```

## Nota sobre Airbyte

Para instalación nueva local, Airbyte ya no recomienda Docker Compose.
Para esta fase, levanta MySQL y PostgreSQL con este compose y corre Airbyte por separado con `abctl`.

Cuando configures el destination PostgreSQL en Airbyte, apunta a:

- Database: `farmacia_dw`
- Schema: `raw`

## Configuración recomendada en Airbyte

### Source MySQL

- Source name: `mysql-farmadb`
- Host: `host.docker.internal`
- Port: `13306`
- Database: `farmadb`
- Username: `root`
- Password: `root`

### Destination PostgreSQL

- Destination name: `postgres-farmacia-raw`
- Host: `host.docker.internal`
- Port: `15432`
- Database: `farmacia_dw`
- Schema: `raw`
- Username: `postgres`
- Password: `postgres`

### Connection

Para esta práctica, usa:

- tablas: `categorias`, `clientes`, `familias`, `pedido_detalles`, `pedidos`, `productos`, `vendedores`
- modo por tabla: `Full refresh | Overwrite`
- frecuencia: `Manual` o `Every 24 hours`

## Limpieza previa recomendada del laboratorio (opcional)

Si ya existe una conexión previa en Airbyte y quieres rehacer la práctica desde cero:

1. elimina la `connection`
2. si deseas una limpieza total, elimina también el `source` y el `destination`
3. limpia el schema `raw` en PostgreSQL antes de volver a sincronizar

Limpieza opcional del schema `raw`:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego:

```sql
DROP SCHEMA raw CASCADE;
CREATE SCHEMA raw;
```

## Validación después del Sync

Después de ejecutar `Sync now` en Airbyte, valida la carga con:

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

## Instalar Airbyte en Windows

### Opción recomendada (PowerShell)

Abre PowerShell como administrador.

#### Paso 1. Instalar `abctl`

Primero consulta los archivos publicados en el release más reciente:

```powershell
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/airbytehq/abctl/releases/latest"
$release.assets | Select-Object -ExpandProperty name
```

Ejemplo de salida:

```text
abctl-v0.30.4-darwin-amd64.tar.gz
abctl-v0.30.4-darwin-arm64.tar.gz
abctl-v0.30.4-linux-amd64.tar.gz
abctl-v0.30.4-linux-arm64.tar.gz
abctl-v0.30.4-windows-amd64.zip
abctl-v0.30.4-windows-arm64.zip
abctl_0.30.4_checksums.txt
```

Luego elige el archivo que corresponda a tu máquina:

- `windows-amd64.zip`: Windows de 64 bits sobre Intel/AMD
- `windows-arm64.zip`: Windows sobre ARM

Después ejecuta este bloque en la misma ventana de PowerShell. Aquí se usa `windows-amd64` como ejemplo:

```powershell
$asset = $release.assets | Where-Object { $_.name -eq "abctl-v0.30.4-windows-amd64.zip" } | Select-Object -First 1
$asset | Format-List name,browser_download_url
if (-not $asset) { throw "No se encontro el asset de Windows AMD64 en el release mas reciente de abctl." }
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$env:TEMP\abctl.zip"
Expand-Archive -Path "$env:TEMP\abctl.zip" -DestinationPath "C:\abctl" -Force
$abctlExe = Get-ChildItem -Path "C:\abctl" -Filter "abctl.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName
if (-not $abctlExe) { throw "No se encontro abctl.exe despues de descomprimir el archivo." }
$abctlDir = Split-Path $abctlExe -Parent
$env:Path += ";$abctlDir"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "Machine")
abctl version
```

#### Paso 2. Desplegar Airbyte local

Con Docker Desktop ya iniciado, ejecuta:

```powershell
abctl local install --port 8010
abctl local credentials
```

Airbyte debería quedar disponible en `http://localhost:8010`.

Para obtener la contraseña, ejecuta:

```powershell
abctl local credentials
```
