-- =========================================
-- 4_cargar_datos_didacticos_bi.sql
-- Ampliacion manual de datos para analisis BI
--
-- Ejecutar despues de explicar el ETL simple con los datos minimos
-- de farmadb.sql. Este script agrega volumen y temporalidad para
-- practicas de Power BI: OLAP, storytelling, KPIs, rankings y
-- comparativos por anio/mes/dia de semana.
-- =========================================

USE farmadb;

-- =========================================
-- 1. CLIENTES Y VENDEDORES ADICIONALES
-- =========================================

INSERT IGNORE INTO `clientes` (`id`, `nombre`) VALUES
(3, 'Clinica Los Andes'),
(4, 'Botica Central'),
(5, 'Hospital Regional'),
(6, 'Farmacia Salud'),
(7, 'Consultorio Vida'),
(8, 'Policlinico Norte'),
(9, 'Botica Popular'),
(10, 'Centro Medico Juliaca');

INSERT IGNORE INTO `vendedores` (`id`, `nombre`) VALUES
(3, 'Maria Quispe'),
(4, 'Luis Mamani'),
(5, 'Rosa Condori'),
(6, 'Jorge Apaza');

-- =========================================
-- 2. PEDIDOS DIDACTICOS
-- =========================================
-- Datos didacticos para BI:
-- - 144 pedidos adicionales entre 2024 y 2025
-- - varias fechas, meses, dias de semana, clientes, vendedores y estados
-- - permite analizar tendencias, comparativos anuales, rankings y KPIs

INSERT IGNORE INTO `pedidos` (
  `id`,
  `fecha_creacion`,
  `fecha_confirmacion`,
  `fecha_envio`,
  `fecha_entrega`,
  `fecha_pago`,
  `estado`,
  `cliente_id`,
  `direccion`,
  `vendedor_id`
)
WITH RECURSIVE seq AS (
  SELECT 0 AS n
  UNION ALL
  SELECT n + 1
  FROM seq
  WHERE n < 143
),
base AS (
  SELECT
    n,
    DATE_ADD(
      DATE_ADD('2024-01-03 08:00:00', INTERVAL (n * 5) DAY),
      INTERVAL MOD(n * 37, 480) MINUTE
    ) AS fecha_base
  FROM seq
)
SELECT
  n + 3 AS id,
  fecha_base AS fecha_creacion,
  DATE_ADD(fecha_base, INTERVAL (20 + MOD(n * 11, 160)) MINUTE) AS fecha_confirmacion,
  DATE_ADD(fecha_base, INTERVAL (90 + MOD(n * 13, 240)) MINUTE) AS fecha_envio,
  DATE_ADD(fecha_base, INTERVAL (8 + MOD(n * 7, 42)) HOUR) AS fecha_entrega,
  CASE
    WHEN MOD(n, 4) IN (0, 1)
      THEN DATE_ADD(fecha_base, INTERVAL (2 + MOD(n, 5)) DAY)
    ELSE NULL
  END AS fecha_pago,
  CASE
    WHEN MOD(n, 4) = 0 THEN 'Pagado'
    WHEN MOD(n, 4) = 1 THEN 'Entregado'
    WHEN MOD(n, 4) = 2 THEN 'Enviado'
    ELSE 'Confirmado'
  END AS estado,
  1 + MOD(n, 10) AS cliente_id,
  CONCAT('Juliaca zona ', 1 + MOD(n, 8), ' pedido ', n + 3) AS direccion,
  1 + MOD(n, 6) AS vendedor_id
FROM base;

-- =========================================
-- 3. LINEAS DE DETALLE DIDACTICAS
-- =========================================
-- Cada pedido adicional recibe 3 productos. Los importes se calculan
-- desde la tabla productos para mantener consistencia con el OLTP.

INSERT IGNORE INTO `pedido_detalles` (
  `pedido_id`,
  `producto_id`,
  `cantidad`,
  `precio_compra_unitario`,
  `precio_venta_unitario`,
  `total_descuento_unitario`,
  `igv_unitario`
)
WITH RECURSIVE seq AS (
  SELECT 0 AS n
  UNION ALL
  SELECT n + 1
  FROM seq
  WHERE n < 143
),
lineas AS (
  SELECT 1 AS linea
  UNION ALL
  SELECT 2
  UNION ALL
  SELECT 3
),
detalle AS (
  SELECT
    n,
    linea,
    1 + MOD((n * 3) + (linea * 5), 22) AS producto_id,
    CAST(5 + MOD((n + 1) * (linea + 3), 45) AS DECIMAL(9,2)) AS cantidad,
    CASE
      WHEN MOD(n + linea, 6) = 0 THEN 1.50
      WHEN MOD(n + linea, 6) = 1 THEN 1.00
      WHEN MOD(n + linea, 6) = 2 THEN 0.50
      ELSE 0.00
    END AS descuento_unitario
  FROM seq
  CROSS JOIN lineas
)
SELECT
  d.n + 3 AS pedido_id,
  d.producto_id,
  d.cantidad,
  p.precio_compra AS precio_compra_unitario,
  p.precio_venta AS precio_venta_unitario,
  d.descuento_unitario AS total_descuento_unitario,
  ROUND((p.precio_venta - d.descuento_unitario) * 0.18, 2) AS igv_unitario
FROM detalle AS d
INNER JOIN productos AS p
  ON d.producto_id = p.id;

-- =========================================
-- 4. VALIDACION RAPIDA
-- =========================================

SELECT
  COUNT(*) AS clientes
FROM clientes;

SELECT
  COUNT(*) AS vendedores
FROM vendedores;

SELECT
  COUNT(*) AS pedidos,
  COUNT(DISTINCT DATE(fecha_creacion)) AS dias_con_pedidos,
  MIN(fecha_creacion) AS primera_fecha,
  MAX(fecha_creacion) AS ultima_fecha
FROM pedidos;

SELECT
  COUNT(*) AS lineas_detalle
FROM pedido_detalles;

SELECT
  YEAR(fecha_creacion) AS anio,
  MONTH(fecha_creacion) AS mes,
  COUNT(*) AS pedidos
FROM pedidos
GROUP BY
  YEAR(fecha_creacion),
  MONTH(fecha_creacion)
ORDER BY
  anio,
  mes;
