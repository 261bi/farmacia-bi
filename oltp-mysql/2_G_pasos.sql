-- =========================================
-- 2_G_pasos.sql
-- Construccion pedagogica de la vista G
-- =========================================
--
-- Este archivo NO es el script operativo final del ETL.
-- Su objetivo es ayudar a entender, paso a paso, como se construye
-- la logica de integracion que luego termina en la vista vw_g_ventas.
--
-- Para ejecutar el ETL completo usa:
--   1_dm.sql
--   3_poblar.sql
--
-- Aqui la idea es:
--   1. entender el grano
--   2. construir metricas de a poco
--   3. agregar contexto de negocio
--   4. agregar tiempos operativos
--   5. reconocer que esa consulta final ya equivale a la vista G
--
-- Recomendacion pedagogica:
-- ejecuta este archivo por bloques o por sentencias,
-- no necesariamente de principio a fin como un script productivo.

USE farmadb;
SET lc_time_names = 'es_ES';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


-- ==========================================================
-- BLOQUE 0. IDEA CENTRAL
-- ==========================================================
-- La vista G representa una tabla logica intermedia para:
-- - unir pedidos con pedido_detalles
-- - recuperar cliente, vendedor y producto
-- - recuperar categoria y familia
-- - calcular ventas, costos, descuentos y margen
-- - calcular tiempos del proceso del pedido
--
-- La unidad base o grano fino de G es:
--   una linea de pedido por producto
--
-- Eso significa que:
-- - un pedido con 1 producto genera 1 fila en G
-- - un pedido con 3 productos genera 3 filas en G
--
-- Sobre esa unidad base se calculan las metricas.


-- ==========================================================
-- PASO 1. METRICA BASE: VENTA_NETA
-- ==========================================================
-- Empezamos por la medida mas importante:
--   venta_neta = cantidad * (precio_venta_unitario - descuento_unitario)
--
-- Aqui todavia no agregamos nada.
-- Solo queremos ver la fila base del hecho.

SELECT
    pe.id AS pedido_id,                  -- identifica el pedido
    ped.producto_id,                     -- identifica el producto de la linea
    ped.cantidad * (
        ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
    ) AS venta_neta                      -- venta despues del descuento
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id;

-- Si quieres verla con la forma de una subconsulta derivada G:

SELECT
    G.pedido_id,
    G.producto_id,
    G.venta_neta
FROM (
    SELECT
        pe.id AS pedido_id,
        ped.producto_id,
        ped.cantidad * (
            ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
        ) AS venta_neta
    FROM pedidos AS pe
    INNER JOIN pedido_detalles AS ped
        ON pe.id = ped.pedido_id
) AS G;

-- Ejemplo de agregacion SOLO para validar la venta_neta total:

SELECT
    SUM(G.venta_neta) AS ventas_netas
FROM (
    SELECT
        pe.id AS pedido_id,
        ped.producto_id,
        ped.cantidad * (
            ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
        ) AS venta_neta
    FROM pedidos AS pe
    INNER JOIN pedido_detalles AS ped
        ON pe.id = ped.pedido_id
) AS G;


-- ==========================================================
-- PASO 2. VARIAS METRICAS POR LINEA DE PEDIDO
-- ==========================================================
-- Ahora agregamos:
-- - venta_bruta
-- - descuento_total
-- - venta_neta
-- - costo_total
--
-- Seguimos al mismo grano:
--   una fila por linea de pedido por producto

SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    ped.cantidad,
    ped.precio_compra_unitario,
    ped.precio_venta_unitario,
    COALESCE(ped.total_descuento_unitario, 0) AS descuento_unitario,
    ped.cantidad * ped.precio_venta_unitario AS venta_bruta,
    ped.cantidad * COALESCE(ped.total_descuento_unitario, 0) AS descuento_total,
    ped.cantidad * (
        ped.precio_venta_unitario - COALESCE(ped.total_descuento_unitario, 0)
    ) AS venta_neta,
    ped.cantidad * ped.precio_compra_unitario AS costo_total
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id;


-- ==========================================================
-- PASO 3. AGREGAR MARGEN_BRUTO
-- ==========================================================
-- margen_bruto = venta_neta - costo_total

SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    ped.cantidad,
    ped.precio_compra_unitario,
    ped.precio_venta_unitario,
    COALESCE(ped.total_descuento_unitario, 0) AS descuento_unitario,
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
    ) AS margen_bruto
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id;


-- ==========================================================
-- PASO 4. AGREGAR PCT_MARGEN_BRUTO
-- ==========================================================
-- pct_margen_bruto = margen_bruto / venta_neta
--
-- Ojo:
-- - este valor se guarda como decimal
-- - por ejemplo, 0.30 significa 30%

SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    ped.cantidad,
    ped.precio_compra_unitario,
    ped.precio_venta_unitario,
    COALESCE(ped.total_descuento_unitario, 0) AS descuento_unitario,
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
    END AS pct_margen_bruto
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id;


-- ==========================================================
-- PASO 5. AGREGAR CONTEXTO DEL PEDIDO
-- ==========================================================
-- Ahora añadimos:
-- - cliente_id
-- - vendedor_id
-- - fecha
-- - estado
--
-- Con esto la fila ya no solo tiene metricas;
-- tambien tiene contexto analitico del pedido.

SELECT
    pe.id AS pedido_id,
    ped.producto_id,
    pe.cliente_id,
    pe.vendedor_id,
    DATE(pe.fecha_creacion) AS fecha,
    pe.estado,
    ped.cantidad,
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
    END AS pct_margen_bruto
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id;


-- ==========================================================
-- PASO 6. AGREGAR PRODUCTO, CATEGORIA Y FAMILIA
-- ==========================================================
-- Aqui enriquecemos la fila con la jerarquia comercial:
-- familia -> categoria -> producto
--
-- Esta misma logica luego alimentara dim_producto.

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
    END AS pct_margen_bruto
FROM pedidos AS pe
INNER JOIN pedido_detalles AS ped
    ON pe.id = ped.pedido_id
INNER JOIN productos AS p
    ON ped.producto_id = p.id
INNER JOIN categorias AS c
    ON p.categoria_id = c.id
INNER JOIN familias AS f
    ON c.familia_id = f.id;


-- ==========================================================
-- PASO 7. AGREGAR TIEMPOS OPERATIVOS
-- ==========================================================
-- Ahora incorporamos:
-- - minutos_confirmacion
-- - minutos_despacho
-- - horas_entrega
-- - horas_lead_time
--
-- Con este paso ya tenemos practicamente la vista G completa.

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


-- ==========================================================
-- PASO 8. CONVERTIR LA CONSULTA FINAL EN LA VISTA G
-- ==========================================================
-- Ahora si, reconocemos que la consulta completa ya equivale
-- a la vista logica G.

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


-- ==========================================================
-- PASO 9. VALIDAR LA VISTA
-- ==========================================================

SELECT * FROM vw_g_ventas;

-- La cantidad de filas de G debe coincidir con la cantidad
-- de filas de pedido_detalles, porque el grano es:
--   una linea de pedido por producto

SELECT
    (SELECT COUNT(*) FROM vw_g_ventas) AS total_g,
    (SELECT COUNT(*) FROM pedido_detalles) AS total_detalle;


-- ==========================================================
-- PASO 10. RECIEN DESPUES USAR G PARA POBLAR FACT_VENTAS
-- ==========================================================
-- Aqui ya no estamos explicando solo la construccion de G:
-- ahora la usamos para poblar la tabla de hechos.
-- El INSERT operativo real vive en 3_poblar.sql.
-- Aqui solo lo dejamos como referencia para cerrar la idea completa.
/* -- esto ya fue ejecutado en 3_poblar.sql
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
*/

-- Si quieres comprobar que la carga final salio bien,
-- ejecuta las validaciones operativas en 3_poblar.sql.


-- encontrarás ejemplos como:

SELECT * FROM fact_ventas;

-- validar que el número de filas de fact_ventas coincide con el número de filas de la vista G, 
-- porque cada línea de pedido por producto se convierte en una fila en fact_ventas.
select
    (SELECT COUNT(*) FROM fact_ventas) AS total_fact,
    (SELECT COUNT(*) FROM pedido_detalles) AS total_detalle;
