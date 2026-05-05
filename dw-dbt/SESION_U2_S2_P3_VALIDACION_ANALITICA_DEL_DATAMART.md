# Sesión U2 S2 P3: Validación analítica del DataMart

## 1. Título

Validación analítica del DataMart construido con Airbyte, PostgreSQL y dbt.

## 2. Objetivo

Validar que la réplica en `raw`, la transformación en `staging` y el modelo final en `marts` responden correctamente al caso de negocio y mantienen consistencia con el OLTP `farmadb`.

En esta práctica, el foco principal ya no es construir el pipeline, sino comprobar que el DataMart final:

- conserva el grano esperado
- responde consultas analíticas coherentes
- mantiene consistencia en sus KPIs clave

## 3. Relación con las prácticas previas

Esta práctica continúa directamente desde:

1. [SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
2. [SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)

## 4. Dónde entran los tests de dbt en esta práctica

En esta `P3`, además de ejecutar consultas manuales de validación, ya conviene introducir tests reales de `dbt`.

En el proyecto actual hay dos niveles:

- tests genericos definidos en `models/marts/marts.yml`
- tests singulares definidos en `tests/*.sql`

### 4.1 Qué hace `marts.yml`

El archivo:

- `models/marts/marts.yml`

define tests genericos sobre columnas y relaciones, por ejemplo:

- `not_null`
- `unique`
- `relationships`
- `accepted_values`

dbt lee ese archivo YAML y genera automáticamente las consultas SQL de validación.

### 4.2 Qué hacen los archivos en `tests/`

Los archivos en:

- `tests/fact_ventas_grain.sql`
- `tests/fact_ventas_metricas.sql`

son tests singulares.

Se usan para reglas más especificas del negocio, por ejemplo:

- que no existan duplicados por `pedido_id + producto_id`
- que `venta_neta = venta_bruta - descuento_total`
- que `margen_bruto = venta_neta - costo_total`

### 4.3 Cómo interpreta dbt un test

En dbt, un test pasa si devuelve:

- `0 filas`

Y falla si devuelve:

- una o más filas con problemás

### 4.4 Comando recomendado

Dentro del contenedor `dbt`, puedes ejecutar:

```bash
cd /usr/app/farmacia_bi
dbt test --select marts
```

Con eso, dbt ejecuta los tests genericos declarados para `marts` y también los tests singulares relaciónados.

## 5. Alcance de esta validación

La `P1` ya valido la ingesta hacia `raw` y la `P2` ya valido la construcción física de `staging` y `marts`.

Por eso, en esta `P3` solo haremos una comprobacion mínima de capas y luego concentraremos la atencion en:

- el grano de `fact_ventas`
- la consistencia de los KPIs
- el uso analítico del modelo estrella

## 6. Validación mínima de capas

### 6.1 Validar `raw`

```sql
\dt raw.*
SELECT COUNT(*) FROM raw.clientes;
SELECT COUNT(*) FROM raw.productos;
SELECT COUNT(*) FROM raw.pedidos;
SELECT COUNT(*) FROM raw.pedido_detalles;
```

### 6.2 Validar `staging`

```sql
\dv staging.*
SELECT * FROM staging.stg_pedidos LIMIT 10;
SELECT * FROM staging.stg_pedido_detalles LIMIT 10;
```

### 6.3 Validar `marts`

```sql
\dt marts.*
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.fact_ventas LIMIT 20;
```

## 7. Validación del grano del hecho

El grano esperado es:

- una fila por línea de pedido por producto

```sql
SELECT COUNT(*) AS total_raw_detalle
FROM raw.pedido_detalles;

SELECT COUNT(*) AS total_fact
FROM marts.fact_ventas;
```

Si el modelo esta correcto, ambos conteos deben coincidir.

```sql
SELECT
    pedido_id,
    producto_id,
    COUNT(*) AS repeticiones
FROM marts.fact_ventas
GROUP BY pedido_id, producto_id
HAVING COUNT(*) > 1;
```

## 8. Validación de KPIs comerciales

### 8.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas_dm
FROM marts.fact_ventas;

SELECT
    SUM(cantidad * (precio_venta_unitario - COALESCE(total_descuento_unitario, 0))) AS ventas_netas_raw
FROM raw.pedido_detalles;
```

Ambos resultados deben coincidir.

### 8.2 Unidades vendidas

```sql
SELECT SUM(cantidad_vendida) AS unidades_dm
FROM marts.fact_ventas;

SELECT SUM(cantidad) AS unidades_raw
FROM raw.pedido_detalles;
```

Ambos resultados deben coincidir.

## 9. Validación de dimensiones

```sql
SELECT * FROM marts.dim_cliente LIMIT 10;
SELECT * FROM marts.dim_vendedor LIMIT 10;
SELECT * FROM marts.dim_producto LIMIT 10;
SELECT * FROM marts.dim_fecha LIMIT 10;
SELECT * FROM marts.dim_estado_pedido LIMIT 10;
```

Aquí no buscamos revisar cada columna una por una, sino comprobar que las dimensiones existen, cargaron datos y pueden servir como ejes de análisis del hecho.

## 10. Consultas analíticas del caso

### 10.1 Ventas por producto

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

### 10.2 Ventas por cliente

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

### 10.3 Tiempos operativos

```sql
SELECT
    AVG(minutos_confirmacion) AS promedio_confirmacion,
    AVG(minutos_despacho) AS promedio_despacho,
    AVG(horas_entrega) AS promedio_entrega,
    AVG(horas_lead_time) AS promedio_lead_time
FROM marts.fact_ventas;
```

## 11. Evidencias a entregar

- captura de tablas en `raw`
- captura de vistas en `staging`
- captura de tablas en `marts`
- captura de `dbt test --select marts`
- captura del conteo `raw.pedido_detalles` vs `marts.fact_ventas`
- captura de una validación de KPI comercial
- captura de una consulta analítica final

## 12. Cierre

Con esta práctica se cierra la sesión 2 del pipeline BI con herramientas. El estudiante valida que:

- Airbyte replica correctamente desde `farmadb`
- dbt transforma correctamente desde `raw` hacia `staging` y `marts`
- el modelo final responde al caso de negocio
- `fact_ventas` conserva el grano esperado
- el DataMart puede responder preguntas comerciales y operativas básicas
