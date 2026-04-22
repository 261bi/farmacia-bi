SELECT COUNT(*) AS total_raw_detalle
FROM raw.pedido_detalles;

SELECT COUNT(*) AS total_fact
FROM marts.fact_ventas;

-- 7.1 Ventas netas

SELECT SUM(venta_neta) AS ventas_netas_dm
FROM marts.fact_ventas;

SELECT
    SUM(cantidad * (precio_venta_unitario - COALESCE(total_descuento_unitario, 0))) AS ventas_netas_raw
FROM raw.pedido_detalles;

