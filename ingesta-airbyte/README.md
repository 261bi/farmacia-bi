# Ingesta Airbyte

## Propósito

Esta carpeta documenta el uso de Airbyte como módulo de ingesta para mover datos desde una fuente operativa hacia una base analítica.

La lógica es reutilizable en otros proyectos donde se necesite:

- conectar una fuente transaccional
- réplicar datos hacia una capa de aterrizaje
- dejar lista la entrada para una fase posterior de transformación

## Rol en la arquitectura

De forma general, Airbyte cumple este rol:

```text
Fuente operativa -> Airbyte -> destino analitico
```

En este repositorio, se aplica asi:

```text
MySQL (farmadb) -> Airbyte -> PostgreSQL (farmacia_dw.raw)
```

## Prerequisitos

Antes de usar este módulo deben estar operativos:

- `oltp-mysql/`
- `dw-pg/`
- Docker Desktop
- Airbyte local con `abctl`

## Instalacion de Airbyte en Windows

Trabaja Airbyte local con `abctl`.

### Opcion recomendada (PowerShell)

Abre PowerShell como administrador.

### Paso 1. Instalar `abctl`

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

Luego elige el archivo que corresponda a tu maquína:

- `windows-amd64.zip`: Windows de 64 bits sobre Intel/AMD
- `windows-arm64.zip`: Windows sobre ARM

Despues ejecuta este bloque en la misma ventana de PowerShell. Aquí se usa `windows-amd64` como ejemplo:

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

### Paso 2. Desplegar Airbyte local

Con Docker Desktop ya iniciado, ejecuta:

```powershell
abctl local install --port 8010
abctl local credentials
```

Airbyte debería quedar disponible en:

```text
http://localhost:8010
```

Para obtener la contrasena, ejecuta:

```powershell
abctl local credentials
```

## Operación mínima

### 1. Verificar Airbyte local

```powershell
abctl version
abctl local credentials
```

Interfaz esperada:

```text
http://localhost:8010
```

### 2. Verificar componentes auxiliares

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose ps

cd C:\261bi\farmacia-bi\dw-pg
docker compose ps
```

### 3. Configurar la réplicacion

Desde la interfaz de Airbyte:

- crea o selecciona el `source`
- crea o selecciona el `destination`
- crea la `connection`
- ejecuta `Sync now`

## Validación mínima

Verifica que los datos hayan aterrizado en la base analítica destino:

```powershell
docker exec -it farmacia-dw-pg psql -U postgres -d farmacia_dw
```

Luego:

```sql
\dt raw.*
select * from raw.categorias limit 10;
select * from raw.productos limit 10;
select * from raw.pedidos limit 10;
```

## Integración

De forma general, este módulo:

- consume datos desde una fuente operativa
- los replica hacia una capa de aterrizaje
- deja lista la entrada para una fase de transformación posterior

En `farmacia-bi`, eso significa:

- leer desde `oltp-mysql/`
- escribir en `dw-pg/` schema `raw`
- dejar preparada la entrada para `dw-dbt/`

## Guia relaciónada

La configuración detallada del caso `farmacia-bi` esta en:

- [SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
