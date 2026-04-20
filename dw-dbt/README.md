# DW dbt

Este directorio contiene el entorno base para trabajar con `dbt` sobre PostgreSQL usando Docker.

## Objetivo

Levantar un contenedor con `dbt-core` y `dbt-postgres` para construir el diseño físico del `Data Warehouse` y los `Data Marts` a partir de la capa `raw` ya cargada por Airbyte.

## Archivos

- `Dockerfile`: imagen base con Python 3.11, `dbt-core` y `dbt-postgres`
- `docker-compose.yml`: servicio `dbt` para desarrollo local

## Levantar el contenedor

Ubícate en:

```powershell
cd C:\261bi\farmacia-bi\dw-dbt
```

Construye y levanta el servicio:

```powershell
docker compose up -d --build
```

## Verificar el contenedor

```powershell
docker compose ps
```

Resultado esperado:

- contenedor `farmacia-dw-dbt` en estado `Up`

## Ingresar al contenedor

```powershell
docker exec -it farmacia-dw-dbt bash
```

## Verificar dbt

Dentro del contenedor, ejecuta:

```bash
dbt --version
```

Debes ver instalados:

- `dbt-core`
- `dbt-postgres`

## Flujo recomendado de trabajo

Dentro del contenedor:

```bash
cd /usr/app/farmacia_bi
dbt debug
dbt run --select staging
dbt run --select +marts
dbt run --select +fact_ventas
```

## Modelos actuales del proyecto

### Staging

- `stg_clientes`
- `stg_vendedores`
- `stg_familias`
- `stg_categorias`
- `stg_productos`
- `stg_pedidos`
- `stg_pedido_detalles`

### Marts

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

## Flujo esperado del proyecto

```text
MySQL -> Airbyte -> PostgreSQL raw -> dbt staging -> dbt marts
```

## Nota de diseño

En este proyecto:

- `staging` se construye por tabla fuente relevante del OLTP
- `dim_producto` queda denormalizada con atributos de categoría y familia
- `fact_ventas` se construye con grano de una fila por línea de pedido por producto

## Nota

Este contenedor no ejecuta `dbt` automáticamente al iniciar.
Queda en modo interactivo para que puedas entrar y trabajar paso a paso durante la práctica.
