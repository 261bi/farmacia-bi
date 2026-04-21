-- =========================================
-- 3_poblar.sql
-- ETL manual del DataMart dentro de farmadb
-- Bloques:
-- 1. Configuracion
-- 2. Carga de dimensiones
-- 3. Construccion de vw_g_ventas
-- 4. Carga de fact_ventas
-- 5. Validaciones finales
-- =========================================


-- =========================================
-- 1. CONFIGURACION
-- =========================================

USE farmadb;
SET lc_time_names = 'es_ES';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- SELECT @@lc_time_names;
-- set @day_offset = 1; -- sunday SET DATEFIRST 1 ;


-- =========================================
-- 2. CARGA DE DIMENSIONES
-- =========================================

-- Recomendacion:
-- si vas a recargar este script varias veces, limpia primero:
-- DELETE FROM fact_ventas;
-- DELETE FROM dim_estado_pedido;
-- DELETE FROM dim_fecha;
-- DELETE FROM dim_producto;
-- DELETE FROM dim_vendedor;
-- DELETE FROM dim_cliente;

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


-- =========================================
-- 3. CONSTRUCCION DE VW_G_VENTAS
-- =========================================
-- La vista G representa una tabla logica intermedia para:
-- - unir pedidos con pedido_detalles
-- - recuperar cliente y vendedor
-- - recuperar producto, categoria y familia
-- - calcular ventas, costos, descuentos y margen
-- - calcular tiempos del proceso del pedido
--
-- Logica de formulas:
-- costo_total      = cantidad * precio_compra_unitario
-- venta_bruta      = cantidad * precio_venta_unitario
-- descuento_total  = cantidad * descuento_unitario
-- venta_neta       = cantidad * (precio_venta_unitario - descuento_unitario)
-- margen_bruto     = venta_neta - costo_total
-- pct_margen_bruto = margen_bruto / venta_neta

CREATE OR REPLACE VIEW vw_g_ventas AS
SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    pe.cliente_id,
    pe.vendedor_id,
    DATE(pe.fecha_creacion) AS fecha,
    pe.estado,
    p.codigo AS codigo_producto,
    CONCAT(
        p.nombre, ' ',
        COALESCE(p.concentracion, ''), ' ',
        COALESCE(p.presentacion, ''), ' frac ',
        COALESCE(p.fracciones, '')
    ) AS nombre_producto,
    c.nombre AS nombre_categoria,
    f.nombre AS nombre_familia,
    ped.cantidad,
    ped.precio_compra_unitario,
    ped.precio_venta_unitario,
    COALESCE(ped.total_descuento_unitario, 0) AS descuento_unitario,
    ped.igv_unitario,
    ped.cantidad * ped.precio_venta_unitario AS venta_bruta,
    ped.cantidad * COALESCE(ped.total_descuento_unitario, 0) AS descuento_total,
    ped.cantidad * (
        ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
    ) AS venta_neta,
    ped.cantidad * ped.precio_compra_unitario AS costo_total,
    (
        ped.cantidad * (
            ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
        )
    ) - (
        ped.cantidad * ped.precio_compra_unitario
    ) AS margen_bruto,
    CASE
        WHEN ped.cantidad * (
            ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
        ) = 0 THEN 0
        ELSE (
            (
                ped.cantidad * (
                    ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
                )
                - ped.cantidad * ped.precio_compra_unitario
            )
            / (
                ped.cantidad * (
                    ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
                )
            )
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


-- =========================================
-- 4. CARGA DE FACT_VENTAS
-- =========================================

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


-- =========================================
-- 5. VALIDACIONES FINALES
-- =========================================

-- 5.1 Validar la vista
SELECT * FROM vw_g_ventas;

-- 5.2 Validar que el numero de filas de la vista G coincide
-- con el numero de filas de pedido_detalles
SELECT
    (SELECT COUNT(*) FROM vw_g_ventas) AS total_g,
    (SELECT COUNT(*) FROM pedido_detalles) AS total_detalle;

-- 5.3 Validar la tabla de hechos
SELECT * FROM fact_ventas;

-- 5.4 Validar que el numero de filas de fact_ventas coincide
-- con el numero de filas de pedido_detalles
SELECT
    (SELECT COUNT(*) FROM fact_ventas) AS total_fact,
    (SELECT COUNT(*) FROM pedido_detalles) AS total_detalle;

-- 5.5 Validar ventas netas desde el DataMart
SELECT
    SUM(venta_neta) AS ventas_netas_dm
FROM fact_ventas;

-- 5.6 Validar ventas netas desde el OLTP
SELECT
    SUM(
        cantidad * (
            precio_venta_unitario - COALESCE(total_descuento_unitario, 0)
        )
    ) AS ventas_netas_oltp
FROM pedido_detalles;

-- 5.7 Validar que fact_ventas coincide con vw_g_ventas
SELECT
    g.venta_neta_total_g,
    f.venta_neta_total_fact,
    g.venta_neta_total_g - f.venta_neta_total_fact AS diferencia
FROM (
    SELECT SUM(venta_neta) AS venta_neta_total_g
    FROM vw_g_ventas
) AS g
CROSS JOIN (
    SELECT SUM(venta_neta) AS venta_neta_total_fact
    FROM fact_ventas
) AS f;

-- 5.8 Otra validacion, fila por fila usando dimensiones como puente
SELECT
    SUM(f.venta_neta) AS venta_neta_fact,
    SUM(g.venta_neta) AS venta_neta_g,
    SUM(g.venta_neta) - SUM(f.venta_neta) AS diferencia
FROM fact_ventas AS f
INNER JOIN dim_fecha AS df
    ON f.fecha_key = df.fecha_key
INNER JOIN dim_cliente AS dc
    ON f.cliente_key = dc.cliente_key
INNER JOIN dim_vendedor AS dv
    ON f.vendedor_key = dv.vendedor_key
INNER JOIN dim_producto AS dp
    ON f.producto_key = dp.producto_key
INNER JOIN dim_estado_pedido AS de
    ON f.estado_key = de.estado_key
INNER JOIN vw_g_ventas AS g
    ON f.pedido_id = g.pedido_id
   AND df.fecha = g.fecha
   AND dc.cliente_id = g.cliente_id
   AND dv.vendedor_id = g.vendedor_id
   AND dp.producto_id = g.producto_id
   AND de.estado_pedido = g.estado;
