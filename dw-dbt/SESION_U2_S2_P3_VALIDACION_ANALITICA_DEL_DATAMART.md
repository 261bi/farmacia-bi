# Sesion U2 S2 P3: Validacion analitica del DataMart

## 1. Titulo

Validacion analitica del DataMart construido con Airbyte, PostgreSQL y dbt.

## 2. Objetivo

Validar que la replica en `raw`, la transformacion en `staging` y el modelo final en `marts` responden correctamente al caso de negocio y mantienen consistencia con el OLTP `farmadb`.

## 3. Relacion con las practicas previas

Esta practica continua directamente desde:

1. [SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
2. [SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)

## 4. Validacion minima de capas

### 4.1 Validar `raw`

```sql
\dt raw.*
SELECT COUNT(*) FROM raw.clientes;
SELECT COUNT(*) FROM raw.productos;
SELECT COUNT(*) FROM raw.pedidos;
SELECT COUNT(*) FROM raw.pedido_detalles;
```

### 4.2 Validar `staging`

```sql
\dv staging.*
SELECT * FROM staging.stg_pedidos LIMIT 10;
SELECT * FROM staging.stg_pedido_detalles LIMIT 10;
```

### 4.3 Validar `marts`

```sql
\dt marts.*
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.fact_ventas LIMIT 20;
```

## 5. Validacion del grano del hecho

El grano esperado es:

- una fila por linea de pedido por producto

```sql
SELECT COUNT(*) AS total_raw_detalle
FROM raw.pedido_detalles;

SELECT COUNT(*) AS total_fact
FROM marts.fact_ventas;
```

```sql
SELECT
    pedido_id,
    producto_id,
    COUNT(*) AS repeticiones
FROM marts.fact_ventas
GROUP BY pedido_id, producto_id
HAVING COUNT(*) > 1;
```

## 6. Validacion de KPIs comerciales

### 6.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas_dm
FROM marts.fact_ventas;

SELECT
    SUM(cantidad * (precio_venta_unitario - COALESCE(total_descuento_unitario, 0))) AS ventas_netas_raw
FROM raw.pedido_detalles;
```

### 6.2 Unidades vendidas

```sql
SELECT SUM(cantidad_vendida) AS unidades_dm
FROM marts.fact_ventas;

SELECT SUM(cantidad) AS unidades_raw
FROM raw.pedido_detalles;
```

## 7. Validacion de dimensiones

```sql
SELECT * FROM marts.dim_cliente LIMIT 10;
SELECT * FROM marts.dim_vendedor LIMIT 10;
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.dim_fecha LIMIT 10;
SELECT * FROM marts.dim_estado_pedido LIMIT 10;
```

## 8. Consultas analiticas del caso

### 8.1 Ventas por producto

```sql
SELECT
    dp.nombre_producto,
    SUM(fv.venta_neta) AS ventas_netas
FROM marts.fact_ventas AS fv
INNER JOIN marts.dim_producto AS dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_producto
ORDER BY ventas_netas DESC;
```

### 8.2 Ventas por cliente

```sql
SELECT
    dc.nombre_cliente,
    SUM(fv.venta_neta) AS ventas_netas
FROM marts.fact_ventas AS fv
INNER JOIN marts.dim_cliente AS dc
    ON fv.cliente_key = dc.cliente_key
GROUP BY dc.nombre_cliente
ORDER BY ventas_netas DESC;
```

### 8.3 Tiempos operativos

```sql
SELECT
    AVG(minutos_confirmacion) AS promedio_confirmacion,
    AVG(minutos_despacho) AS promedio_despacho,
    AVG(horas_entrega) AS promedio_entrega,
    AVG(horas_lead_time) AS promedio_lead_time
FROM marts.fact_ventas;
```

## 9. Evidencias a entregar

- captura de tablas en `raw`
- captura de vistas en `staging`
- captura de tablas en `marts`
- captura del conteo `raw.pedido_detalles` vs `marts.fact_ventas`
- captura de una validacion de KPI comercial
- captura de una consulta analitica final

## 10. Cierre

Con esta practica se cierra la sesion 2 del pipeline BI con herramientas. El estudiante valida que:

- Airbyte replica correctamente desde `farmadb`
- dbt transforma correctamente desde `raw` hacia `staging` y `marts`
- el modelo final responde al caso de negocio
