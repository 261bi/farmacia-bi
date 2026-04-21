# Sesión U2 S1 P2: ETL manual con SQL para dimensiones y hecho mediante la vista G

## 1. Título

ETL manual con SQL para poblar dimensiones y tabla de hechos del DataMart dentro del mismo OLTP, usando una vista integrada denominada `G`.

## 2. Propósito de la sesión

En la sesión anterior se creó físicamente el esquema estrella dentro de `farmadb`. En esta práctica se realizará el proceso ETL manual:

- cargar dimensiones con `INSERT INTO ... SELECT ...`
- construir una vista lógica integrada del negocio
- comprender la función de la vista `G`
- cargar la tabla de hechos `fact_ventas`

Esta sesión es clave porque aquí el estudiante ve de manera explícita cómo se integran varias tablas transaccionales para producir una estructura analítica.

## 3. Relación con la sesión anterior

Esta guía continúa directamente desde:

- [SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md](SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md)

Antes de empezar esta práctica, deben existir ya estas tablas en `farmadb`:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

## 4. Objetivo de la práctica

Implementar manualmente el flujo ETL del DataMart de ventas y ciclo de pedidos usando SQL puro, partiendo desde las tablas transaccionales:

- `clientes`
- `vendedores`
- `productos`
- `categorias`
- `familias`
- `pedidos`
- `pedido_detalles`

## 5. Idea central del ETL manual

En esta práctica se trabajará en tres momentos:

1. poblar dimensiones
2. construir la vista `G`
3. cargar `fact_ventas`

La vista `G` será la pieza central porque concentrará:

- la integración de cabecera y detalle del pedido
- la integración con cliente, vendedor y producto
- la clasificación comercial del producto
- el cálculo de métricas comerciales
- el cálculo de tiempos operativos

Más adelante, cuando se use dbt, esta lógica dejará de vivir en una sola vista monolítica y se repartirá entre `staging` y `marts`. Por eso esta práctica también sirve como puente conceptual hacia la arquitectura moderna.

## 6. Preparación del entorno

Levanta el servicio MySQL del laboratorio:

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

Ingresa al motor:

```powershell
docker exec -it farmacia-oltp-mysql mysql -uroot -proot farmadb
```

## 6.1 Scripts de apoyo de esta sesión

En esta sesión conviene distinguir dos archivos SQL:

- [2_G_pasos.sql](2_G_pasos.sql): guion pedagógico para entender la construcción progresiva de la vista `G`.
- [3_poblar.sql](3_poblar.sql): script operativo final para poblar dimensiones, crear `vw_g_ventas` y cargar `fact_ventas`.

Orden recomendado de ejecución dentro de `oltp-mysql`:

1. [1_dm.sql](1_dm.sql)
2. [2_G_pasos.sql](2_G_pasos.sql)
3. [3_poblar.sql](3_poblar.sql)

## 7. Revisión previa de tablas fuente

Antes de cargar el DataMart, revisa rápidamente las tablas transaccionales:

```sql
SELECT * FROM clientes;
SELECT * FROM vendedores;
SELECT * FROM familias;
SELECT * FROM categorias;
SELECT * FROM productos;
SELECT * FROM pedidos;
SELECT * FROM pedido_detalles;
```

## 8. Configuración previa de la sesión SQL

Antes de comenzar la carga manual de dimensiones y hecho, configura la sesión SQL para trabajar con la base correcta y con nombres de tiempo en español.

```sql
USE farmadb;
SET lc_time_names = 'es_ES';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- SELECT @@lc_time_names;
-- set @day_offset = 1; -- sunday SET DATEFIRST 1 ;
```

### ¿Por qué se hace esta configuración?

- `USE farmadb` asegura que todo el ETL manual se ejecute sobre la base donde conviven OLTP y DataMart en esta práctica.
- `SET lc_time_names = 'es_ES'` permite que `DAYNAME()` y `MONTHNAME()` devuelvan nombres en español.
- `SET sql_mode = ...` ayuda a trabajar con una configuración más estricta y controlada durante la carga.

## 9. Carga manual de dimensiones

### 9.1 Cargar `dim_cliente`

```sql
INSERT INTO dim_cliente (
    cliente_id,
    nombre_cliente
)
SELECT
    c.id,
    c.nombre
FROM clientes AS c;
```

Validación:

```sql
SELECT * FROM dim_cliente;
```

### 9.2 Cargar `dim_vendedor`

```sql
INSERT INTO dim_vendedor (
    vendedor_id,
    nombre_vendedor
)
SELECT
    v.id,
    v.nombre
FROM vendedores AS v;
```

Validación:

```sql
SELECT * FROM dim_vendedor;
```

### 9.3 Cargar `dim_producto`

En esta dimensión se integran `productos`, `categorias` y `familias`.

```sql
INSERT INTO dim_producto (
    producto_id,
    codigo_producto,
    nombre_producto,
    precio_compra,
    precio_venta,
    categoria_id,
    nombre_categoria,
    familia_id,
    nombre_familia
)
SELECT
    p.id,
    p.codigo,
    CONCAT(
        p.nombre, ' ',
        COALESCE(p.concentracion, ''), ' ',
        COALESCE(p.presentacion, ''), ' frac ',
        COALESCE(p.fracciones, '')
    ) AS nombre_producto,
    p.precio_compra,
    p.precio_venta,
    c.id,
    c.nombre,
    f.id,
    f.nombre
FROM productos AS p
INNER JOIN categorias AS c
    ON p.categoria_id = c.id
INNER JOIN familias AS f
    ON c.familia_id = f.id;
```

Validación:

```sql
SELECT * FROM dim_producto LIMIT 20;
```

### 9.4 Cargar `dim_fecha`

Para esta primera versión se utilizará `pedidos.fecha_creacion` como fecha analítica principal.

```sql
INSERT INTO dim_fecha (
    fecha_key,
    fecha,
    dia,
    dia_semana_desc,
    mes,
    mes_desc,
    trimestre,
    anio
)
SELECT
    CAST(DATE_FORMAT(p.fecha_creacion, '%Y%m%d') AS UNSIGNED) AS fecha_key,
    DATE(p.fecha_creacion) AS fecha,
    DAY(p.fecha_creacion) AS dia,
    DAYNAME(p.fecha_creacion) AS dia_semana_desc,
    MONTH(p.fecha_creacion) AS mes,
    MONTHNAME(p.fecha_creacion) AS mes_desc,
    QUARTER(p.fecha_creacion) AS trimestre,
    YEAR(p.fecha_creacion) AS anio
FROM pedidos AS p
GROUP BY DATE(p.fecha_creacion)
ORDER BY DATE(p.fecha_creacion);
```

Validación:

```sql
SELECT * FROM dim_fecha;
```

### 9.5 Cargar `dim_estado_pedido`

```sql
INSERT INTO dim_estado_pedido (
    estado_pedido
)
SELECT DISTINCT
    p.estado
FROM pedidos AS p
WHERE p.estado IS NOT NULL;
```

Validación:

```sql
SELECT * FROM dim_estado_pedido;
```

## 10. ¿Qué hace exactamente la vista `G`?

La vista `G` representa una tabla lógica intermedia construida con SQL para:

- unir `pedidos` con `pedido_detalles`
- recuperar cliente y vendedor
- recuperar producto, categoría y familia
- calcular ventas, costos y descuentos
- calcular tiempos del proceso del pedido

En otras palabras, `G` no es todavía la tabla de hechos final, pero sí es la fuente inmediata desde la que luego se cargará `fact_ventas`.

## 11. Construcción de la vista `G`

### 11.1 Crear o reemplazar la vista

```sql
CREATE OR REPLACE VIEW vw_g_ventas AS
SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    pe.cliente_id,
    pe.vendedor_id,
    DATE(pe.fecha_creacion) AS fecha,
    pe.estado,
    p.codigo AS codigo_producto,
    p.nombre AS nombre_producto_base,
    c.nombre AS nombre_categoria,
    f.nombre AS nombre_familia,
    ped.cantidad,
    ped.precio_compra_unitario,
    ped.precio_venta_unitario,
    COALESCE(ped.total_descuento_unitario, 0) AS total_descuento_unitario,
    ped.igv_unitario,
    ped.cantidad * ped.precio_venta_unitario AS venta_bruta,
    ped.cantidad * COALESCE(ped.total_descuento_unitario, 0) AS descuento_total,
    ped.cantidad * (ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)) AS venta_neta,
    ped.cantidad * ped.precio_compra_unitario AS costo_total,
    (ped.cantidad * (ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)))
      - (ped.cantidad * ped.precio_compra_unitario) AS margen_bruto,
    CASE
        WHEN ped.cantidad * (ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)) = 0 THEN 0
        ELSE (
            (
                (ped.cantidad * (ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)))
                - (ped.cantidad * ped.precio_compra_unitario)
            )
            / (ped.cantidad * (ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)))
        )
    END AS pct_margen_bruto,
    TIMESTAMPDIFF(MINUTE, pe.fecha_creacion, pe.fecha_confirmacion) AS minutos_confirmacion,
    TIMESTAMPDIFF(MINUTE, pe.fecha_confirmacion, pe.fecha_envio) AS minutos_despacho,
    ROUND(TIMESTAMPDIFF(SECOND, pe.fecha_envio, pe.fecha_entrega) / 3600, 2) AS horas_entrega,
    ROUND(TIMESTAMPDIFF(SECOND, pe.fecha_creacion, pe.fecha_entrega) / 3600, 2) AS horas_lead_time
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id
INNER JOIN productos AS p
    ON ped.producto_id = p.id
INNER JOIN categorias AS c
    ON p.categoria_id = c.id
INNER JOIN familias AS f
    ON c.familia_id = f.id;
```

### 11.2 Validar la vista

```sql
SELECT * FROM vw_g_ventas;
```

## 12. Cómo leer la vista `G`

La vista `G` debe entenderse en bloques:

### Bloque 1. Base transaccional

- `pedidos`
- `pedido_detalles`

Aquí aparece la unidad base del hecho:

- una línea de pedido por producto

### Bloque 2. Contexto de negocio

- `clientes`
- `vendedores`
- `productos`
- `categorias`
- `familias`

Esto aporta el contexto dimensional del análisis.

### Bloque 3. Cálculo de métricas

Se calculan:

- `venta_bruta`
- `descuento_total`
- `venta_neta`
- `costo_total`
- `margen_bruto`
- `pct_margen_bruto`

### Bloque 4. Cálculo de tiempos

Se calculan:

- `minutos_confirmacion`
- `minutos_despacho`
- `horas_entrega`
- `horas_lead_time`

## 13. Carga de `fact_ventas`

Una vez creadas las dimensiones y la vista `G`, se carga la tabla de hechos.

```sql
INSERT INTO fact_ventas (
    pedido_id,
    fecha_key,
    cliente_key,
    vendedor_key,
    producto_key,
    estado_key,
    cantidad_vendida,
    venta_bruta,
    descuento_total,
    venta_neta,
    costo_total,
    margen_bruto,
    pct_margen_bruto,
    minutos_confirmacion,
    minutos_despacho,
    horas_entrega,
    horas_lead_time,
    pedido_count
)
SELECT
    g.pedido_id,
    df.fecha_key,
    dc.cliente_key,
    dv.vendedor_key,
    dp.producto_key,
    de.estado_key,
    g.cantidad,
    g.venta_bruta,
    g.descuento_total,
    g.venta_neta,
    g.costo_total,
    g.margen_bruto,
    g.pct_margen_bruto,
    g.minutos_confirmacion,
    g.minutos_despacho,
    g.horas_entrega,
    g.horas_lead_time,
    1 AS pedido_count
FROM vw_g_ventas AS g
INNER JOIN dim_fecha AS df
    ON g.fecha = df.fecha
INNER JOIN dim_cliente AS dc
    ON g.cliente_id = dc.cliente_id
INNER JOIN dim_vendedor AS dv
    ON g.vendedor_id = dv.vendedor_id
INNER JOIN dim_producto AS dp
    ON g.producto_id = dp.producto_id
INNER JOIN dim_estado_pedido AS de
    ON g.estado = de.estado_pedido;
```

## 14. Validación de la carga del hecho

```sql
SELECT * FROM fact_ventas;
```

Valida también el número de filas:

```sql
SELECT COUNT(*) AS total_fact_rows
FROM fact_ventas;
```

Y compáralo con:

```sql
SELECT COUNT(*) AS total_detalle_rows
FROM pedido_detalles;
```

La idea es comprobar que el hecho mantiene el detalle base y no se resumió indebidamente.

## 15. Diferencia entre este enfoque y una tabla resumen

En esta práctica la tabla de hechos debe conservar el grano:

- una fila por línea de pedido por producto

Por eso, en esta carga:

- no se usa un `GROUP BY` para consolidar por fecha, cliente, vendedor y producto
- no se hace una tabla resumen adelantada
- primero se conserva el detalle, luego el análisis agregado se realiza en consultas posteriores

## 16. Consultas de verificación rápida

### Verificar ventas por producto

```sql
SELECT
    dp.nombre_producto,
    SUM(fv.venta_neta) AS ventas_netas
FROM fact_ventas AS fv
INNER JOIN dim_producto AS dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_producto
ORDER BY ventas_netas DESC;
```

### Verificar ventas por cliente

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

### Verificar tiempos del proceso

```sql
SELECT
    AVG(minutos_confirmacion) AS promedio_confirmacion,
    AVG(minutos_despacho) AS promedio_despacho,
    AVG(horas_entrega) AS promedio_entrega,
    AVG(horas_lead_time) AS promedio_lead_time
FROM fact_ventas;
```

## 17. Qué debe quedar listo al cerrar esta sesión

Al terminar esta práctica debe quedar:

- `dim_cliente` poblada
- `dim_vendedor` poblada
- `dim_producto` poblada
- `dim_fecha` poblada
- `dim_estado_pedido` poblada
- `vw_g_ventas` creada
- `fact_ventas` cargada

## 18. Qué viene en la siguiente práctica

En la siguiente sesión se trabajará la validación analítica del DataMart manual para:

- contrastar resultados contra el OLTP
- validar métricas
- revisar el comportamiento del esquema estrella
- reconocer límites del enfoque manual dentro del mismo motor transaccional

## 19. Evidencias a entregar

- captura de `SELECT * FROM dim_producto`
- captura de `SELECT * FROM dim_fecha`
- captura de `SELECT * FROM vw_g_ventas`
- captura de `SELECT * FROM fact_ventas`
- explicación breve de qué hace la vista `G`

## 20. Cierre

Esta práctica representa el corazón técnico de la fase manual del DW. Aquí el estudiante transforma datos transaccionales en datos analíticos mediante SQL puro, comprende la lógica de integración del negocio y deja listo el DataMart para su validación posterior.
