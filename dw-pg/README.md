# DW PostgreSQL

Esta carpeta contiene la base PostgreSQL que aloja el `Data Warehouse` y el `DataMart`.

## Servicio

- PostgreSQL 16
- Contenedor: `farmacia-dw-pg`
- Base: `farmacia_dw`

## Levantar

```powershell
cd C:\261bi\farmacia-bi\dw-pg
docker compose up -d
```

## Verificar

```powershell
docker compose ps
```

## Acceso

- Host: `localhost`
- Port: `15432`
- Database: `farmacia_dw`
- User: `postgres`
- Password: `postgres`

## Schemas

La base se organiza en:

- `raw`
- `staging`
- `marts`

Los schemas se crean desde:

- `postgres/init/01_create_schemas.sql`
