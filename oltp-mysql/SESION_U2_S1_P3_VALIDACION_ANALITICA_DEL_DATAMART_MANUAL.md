# Sesión U2 S1 P3: Validación analítica del DataMart manual

## 1. Título

Validación analítica del DataMart manual implementado dentro del mismo OLTP `farmadb`.

## 2. Propósito de la sesión

En la sesión anterior se cargaron las dimensiones y la tabla de hechos del DataMart manual. En esta práctica se validará si el modelo construido responde correctamente a las preguntas analíticas del caso y si las métricas obtenidas son consistentes con la fuente transaccional.

Esta sesión tiene tres objetivos:

- comprobar que el DataMart manual fue cargado correctamente
- validar indicadores y consultas analíticas contra el OLTP
- reconocer las limitaciones del enfoque manual dentro del mismo motor transaccional

## 3. Relación con las sesiones previas

Esta guía continúa directamente desde:

- [SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md](SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md)
- [SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md](SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md)

En términos de scripts, esta validación asume que ya se trabajó en este orden:

1. [1_dm.sql](1_dm.sql)
2. [2_G_pasos.sql](2_G_pasos.sql) (opcional)
3. [3_poblar.sql](3_poblar.sql)

Antes de iniciar esta práctica deben existir y estar pobladas estas tablas:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

Y debe existir además la vista:

- `vw_g_ventas`

## 4. Objetivo de validación

Verificar que el esquema estrella manual responde adecuadamente al problema de negocio oficial:

- análisis comercial
- análisis operativo del ciclo del pedido
- ventas, descuentos y margen
- tiempos de confirmación, despacho, entrega y lead time

## 5. Preparación del entorno

Levanta el MySQL del laboratorio:

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

Ingresa al motor:

```powershell
docker exec -it farmacia-oltp-mysql mysql -uroot -proot farmadb
```

Configura la sesión:

```sql
USE farmadb;
SET lc_time_names = 'es_ES';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
```

## 6. Validación estructural mínima

Confirma que el DataMart manual existe:

```sql
SHOW TABLES LIKE 'dim_%';
SHOW TABLES LIKE 'fact_%';
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

Revisa si las dimensiones y el hecho tienen datos:

```sql
SELECT COUNT(*) AS total_dim_cliente FROM dim_cliente;
SELECT COUNT(*) AS total_dim_vendedor FROM dim_vendedor;
SELECT COUNT(*) AS total_dim_producto FROM dim_producto;
SELECT COUNT(*) AS total_dim_fecha FROM dim_fecha;
SELECT COUNT(*) AS total_dim_estado_pedido FROM dim_estado_pedido;
SELECT COUNT(*) AS total_fact_ventas FROM fact_ventas;
```

## 7. Validación del grano del hecho

El grano oficial del curso es:

- una fila por línea de pedido por producto

Como en la fuente `pedido_detalles` la clave transaccional base es:

- `pedido_id`
- `producto_id`

debemos validar que la cantidad de filas del hecho coincida con el detalle base.

### 7.1 Comparar número de filas

```sql
SELECT COUNT(*) AS total_detalle_rows
FROM pedido_detalles;

SELECT COUNT(*) AS total_fact_rows
FROM fact_ventas;
```

### 7.2 Verificar duplicidad del grano

```sql
SELECT
    pedido_id,
    producto_key,
    COUNT(*) AS repeticiones
FROM fact_ventas
GROUP BY pedido_id, producto_key
HAVING COUNT(*) > 1;
```

Resultado esperado:

- no deben existir repeticiones

## 8. Validación de dimensiones

### 8.1 Validar `dim_cliente`

```sql
SELECT * FROM dim_cliente;
```

Debe reflejar correctamente los clientes de la fuente:

```sql
SELECT id, nombre
FROM clientes;
```

### 8.2 Validar `dim_vendedor`

```sql
SELECT * FROM dim_vendedor;
```

Debe reflejar correctamente los vendedores de la fuente:

```sql
SELECT id, nombre
FROM vendedores;
```

### 8.3 Validar `dim_producto`

```sql
SELECT * FROM dim_producto LIMIT 20;
```

Aquí debe verificarse especialmente que:

- el producto exista
- la categoría esté integrada
- la familia esté integrada
- no existan dimensiones separadas `dim_categoria` ni `dim_familia`

### 8.4 Validar `dim_fecha`

```sql
SELECT * FROM dim_fecha;
```

Debe representar la fecha analítica principal:

- `pedidos.fecha_creacion`

### 8.5 Validar `dim_estado_pedido`

```sql
SELECT * FROM dim_estado_pedido;
```

Debe contener los estados distintos provenientes de:

- `pedidos.estado`

## 9. Validación de la vista `G`

Antes de validar la tabla de hechos, revisa la vista intermedia:

```sql
SELECT * FROM vw_g_ventas;
```

Verifica especialmente:

- `pedido_id`
- `producto_id`
- `cliente_id`
- `vendedor_id`
- `venta_bruta`
- `descuento_total`
- `venta_neta`
- `costo_total`
- `margen_bruto`
- `pct_margen_bruto`
- `minutos_confirmacion`
- `minutos_despacho`
- `horas_entrega`
- `horas_lead_time`

## 10. Validación de KPIs comerciales

### 10.1 Ventas netas

Desde el DataMart:

```sql
SELECT SUM(venta_neta) AS ventas_netas_dm
FROM fact_ventas;
```

Desde la fuente transaccional:

```sql
SELECT
    SUM(cantidad * (precio_venta_unitario - COALESCE(total_descuento_unitario, 0))) AS ventas_netas_oltp
FROM pedido_detalles;
```

### 10.2 Unidades vendidas

Desde el DataMart:

```sql
SELECT SUM(cantidad_vendida) AS unidades_dm
FROM fact_ventas;
```

Desde la fuente:

```sql
SELECT SUM(cantidad) AS unidades_oltp
FROM pedido_detalles;
```

### 10.3 Descuento total otorgado

Desde el DataMart:

```sql
SELECT SUM(descuento_total) AS descuento_dm
FROM fact_ventas;
```

Desde la fuente:

```sql
SELECT SUM(cantidad * COALESCE(total_descuento_unitario, 0)) AS descuento_oltp
FROM pedido_detalles;
```

### 10.4 Margen bruto

Desde el DataMart:

```sql
SELECT SUM(margen_bruto) AS margen_dm
FROM fact_ventas;
```

Desde la fuente:

```sql
SELECT
    SUM(
        (cantidad * (precio_venta_unitario - COALESCE(total_descuento_unitario, 0)))
        - (cantidad * precio_compra_unitario)
    ) AS margen_oltp
FROM pedido_detalles;
```

### 10.5 Ticket promedio por pedido

Desde el DataMart:

```sql
SELECT
    SUM(venta_neta) / COUNT(DISTINCT pedido_id) AS ticket_promedio_dm
FROM fact_ventas;
```

## 11. Validación de KPIs operativos

### 11.1 Tiempo promedio de confirmación

```sql
SELECT AVG(minutos_confirmacion) AS promedio_confirmacion_dm
FROM fact_ventas;
```

### 11.2 Tiempo promedio de despacho

```sql
SELECT AVG(minutos_despacho) AS promedio_despacho_dm
FROM fact_ventas;
```

### 11.3 Tiempo promedio de entrega

```sql
SELECT AVG(horas_entrega) AS promedio_entrega_dm
FROM fact_ventas;
```

### 11.4 Lead time promedio

```sql
SELECT AVG(horas_lead_time) AS promedio_lead_time_dm
FROM fact_ventas;
```

### 11.5 Porcentaje de pedidos entregados a tiempo

Para fines didácticos, usa un umbral de ejemplo, por ejemplo:

- SLA = 24 horas

```sql
SELECT
    ROUND(
        100 * COUNT(DISTINCT CASE WHEN horas_lead_time <= 24 THEN pedido_id END)
        / COUNT(DISTINCT pedido_id),
        2
    ) AS pct_pedidos_a_tiempo
FROM fact_ventas;
```

## 12. Consultas analíticas del caso

### 12.1 Monto total vendido por día, mes y año

```sql
SELECT
    df.fecha,
    df.mes,
    df.anio,
    SUM(fv.venta_neta) AS ventas_netas
FROM fact_ventas AS fv
INNER JOIN dim_fecha AS df
    ON fv.fecha_key = df.fecha_key
GROUP BY df.fecha, df.mes, df.anio
ORDER BY df.fecha;
```

### 12.2 Unidades vendidas por producto

```sql
SELECT
    dp.nombre_producto,
    SUM(fv.cantidad_vendida) AS unidades_vendidas
FROM fact_ventas AS fv
INNER JOIN dim_producto AS dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_producto
ORDER BY unidades_vendidas DESC;
```

### 12.3 Ventas por cliente

```sql
SELECT
    dc.nombre_cliente,
    SUM(fv.venta_neta) AS ventas_netas
FROM fact_ventas AS fv
INNER JOIN dim_cliente AS dc
    ON fv.cliente_key = dc.cliente_key
GROUP BY dc.nombre_cliente
ORDER BY ventas_netas DESC;
```

### 12.4 Ventas y margen por vendedor

```sql
SELECT
    dv.nombre_vendedor,
    SUM(fv.venta_neta) AS ventas_netas,
    SUM(fv.margen_bruto) AS margen_bruto
FROM fact_ventas AS fv
INNER JOIN dim_vendedor AS dv
    ON fv.vendedor_key = dv.vendedor_key
GROUP BY dv.nombre_vendedor
ORDER BY ventas_netas DESC;
```

### 12.5 Margen por categoría y familia

```sql
SELECT
    dp.nombre_familia,
    dp.nombre_categoria,
    SUM(fv.margen_bruto) AS margen_bruto
FROM fact_ventas AS fv
INNER JOIN dim_producto AS dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_familia, dp.nombre_categoria
ORDER BY margen_bruto DESC;
```

### 12.6 Tiempos por estado del pedido

```sql
SELECT
    de.estado_pedido,
    AVG(fv.minutos_confirmacion) AS promedio_confirmacion,
    AVG(fv.minutos_despacho) AS promedio_despacho,
    AVG(fv.horas_entrega) AS promedio_entrega,
    AVG(fv.horas_lead_time) AS promedio_lead_time
FROM fact_ventas AS fv
INNER JOIN dim_estado_pedido AS de
    ON fv.estado_key = de.estado_key
GROUP BY de.estado_pedido;
```

## 13. Qué debe concluir el alumno

Después de esta validación, el estudiante debe ser capaz de concluir:

- que el DataMart manual sí responde a las preguntas analíticas del caso
- que el modelo estrella fue implementado correctamente
- que el hecho conserva el grano definido
- que los KPI comerciales y operativos pueden calcularse desde el DataMart
- que el enfoque manual funciona, pero no es la arquitectura final recomendada

## 14. Limitaciones del enfoque manual

Aunque esta implementación cumple un objetivo pedagógico importante, presenta limitaciones claras:

- OLTP y DataMart conviven en el mismo motor
- el ETL se ejecuta manualmente
- la vista `G` concentra demasiada lógica en un solo bloque
- no existe separación entre `raw`, `staging` y `marts`
- la escalabilidad y el mantenimiento son limitados

Estas limitaciones justifican la siguiente sesión macro del curso:

- Airbyte para la ingesta
- PostgreSQL como DW
- dbt para la transformación y la construcción del DataMart

## 15. Evidencias a entregar

- captura del conteo de filas de `pedido_detalles` y `fact_ventas`
- captura de la validación de ventas netas entre OLTP y DataMart
- captura de una consulta analítica por producto
- captura de una consulta analítica por cliente o vendedor
- explicación breve de si el DataMart manual responde o no al problema del negocio

## 16. Cierre

Con esta práctica se cierra la fase manual de implementación del DW dentro del mismo OLTP. El estudiante ya comprendió:

- cómo se construye físicamente una estrella
- cómo se pueblan dimensiones y hecho
- cómo se valida un DataMart contra la fuente transaccional

Con esta base, el siguiente paso del curso será industrializar el proceso con Airbyte, PostgreSQL y dbt.
