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

## Scripts Manuales Del DataMart

Orden recomendado de trabajo:

1. `1_dm.sql`
2. `2_G_pasos.sql`
3. `3_poblar.sql`

Propósito de cada script:

- `1_dm.sql`: crea físicamente las dimensiones y la tabla de hechos del DataMart manual.
- `2_G_pasos.sql`: explica de forma pedagógica cómo se construye la lógica de la vista `G`.
- `3_poblar.sql`: ejecuta la carga final de dimensiones, `vw_g_ventas` y `fact_ventas`.
