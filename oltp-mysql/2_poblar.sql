USE farmadb;
SET lc_time_names = 'es_ES';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- SELECT @@lc_time_names;
-- set @day_offset = 1; -- sunday SET DATEFIRST 1 ;  


INSERT INTO dim_cliente (
    cliente_id,
    nombre_cliente
)
SELECT
    c.id,
    c.nombre
FROM clientes AS c;

INSERT INTO dim_vendedor (
    vendedor_id,
    nombre_vendedor
)
SELECT
    v.id,
    v.nombre
FROM vendedores AS v;

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

INSERT INTO dim_estado_pedido (
    estado_pedido
)
SELECT DISTINCT
    p.estado
FROM pedidos AS p
WHERE p.estado IS NOT NULL;




/*
La vista `G` representa una tabla lógica intermedia construida con SQL para:

- unir `pedidos` con `pedido_detalles`
- recuperar cliente y vendedor
- recuperar producto, categoría y familia
- calcular ventas, costos y descuentos
- calcular tiempos del proceso del pedido
*/
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

--ELECT * FROM vw_g_ventas;

/*
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

*/

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
    