# OLTP MySQL

Esta carpeta contiene el origen transaccional del proyecto `farmacia-bi`.

## Servicio

- MySQL 8.4
- Contenedor: `farmacia-oltp-mysql`
- Base: `farmadb`

## Levantar

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
```

## Verificar

```powershell
docker compose ps
```

## Acceso

- Host: `localhost`
- Port: `13306`
- Database: `farmadb`
- User: `root`
- Password: `root`

## Inicialización

El script base se encuentra en:

- `mysql/init/farmadb.sql`
