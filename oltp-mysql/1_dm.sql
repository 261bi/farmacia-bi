
CREATE DATABASE IF NOT EXISTS `farmadb` DEFAULT CHARACTER SET latin1 COLLATE latin1_spanish_ci;
USE `farmadb`;

CREATE TABLE IF NOT EXISTS dim_cliente (
    cliente_key INT AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    PRIMARY KEY (cliente_key),
    UNIQUE KEY uk_dim_cliente_id (cliente_id)
);

CREATE TABLE IF NOT EXISTS dim_vendedor (
    vendedor_key INT AUTO_INCREMENT,
    vendedor_id INT NOT NULL,
    nombre_vendedor VARCHAR(100) NOT NULL,
    PRIMARY KEY (vendedor_key),
    UNIQUE KEY uk_dim_vendedor_id (vendedor_id)
);

CREATE TABLE IF NOT EXISTS dim_producto (
    producto_key INT AUTO_INCREMENT,
    producto_id INT NOT NULL,
    codigo_producto VARCHAR(100) NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    precio_compra DECIMAL(9,2),
    precio_venta DECIMAL(9,2),
    categoria_id INT NOT NULL,
    nombre_categoria VARCHAR(100) NOT NULL,
    familia_id INT NOT NULL,
    nombre_familia VARCHAR(100) NOT NULL,
    PRIMARY KEY (producto_key),
    UNIQUE KEY uk_dim_producto_id (producto_id)
);

CREATE TABLE IF NOT EXISTS dim_fecha (
    fecha_key INT NOT NULL,
    fecha DATE NOT NULL,
    dia INT NOT NULL,
    dia_semana_desc VARCHAR(20) NOT NULL,
    mes INT NOT NULL,
    mes_desc VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    anio INT NOT NULL,
    PRIMARY KEY (fecha_key)
);

CREATE TABLE IF NOT EXISTS dim_estado_pedido (
    estado_key INT AUTO_INCREMENT,
    estado_pedido VARCHAR(20) NOT NULL,
    PRIMARY KEY (estado_key),
    UNIQUE KEY uk_dim_estado_pedido (estado_pedido)
);

CREATE TABLE IF NOT EXISTS fact_ventas (
    fact_venta_key BIGINT AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    fecha_key INT NOT NULL,
    cliente_key INT NOT NULL,
    vendedor_key INT NOT NULL,
    producto_key INT NOT NULL,
    estado_key INT NOT NULL,
    cantidad_vendida DECIMAL(9,2) NOT NULL,
    venta_bruta DECIMAL(14,2) NOT NULL,
    descuento_total DECIMAL(14,2) NOT NULL,
    venta_neta DECIMAL(14,2) NOT NULL,
    costo_total DECIMAL(14,2) NOT NULL,
    margen_bruto DECIMAL(14,2) NOT NULL,
    pct_margen_bruto DECIMAL(9,4) NOT NULL,
    minutos_confirmacion INT,
    minutos_despacho INT,
    horas_entrega DECIMAL(10,2),
    horas_lead_time DECIMAL(10,2),
    pedido_count INT NOT NULL,
    PRIMARY KEY (fact_venta_key),
    KEY idx_fact_ventas_fecha_key (fecha_key),
    KEY idx_fact_ventas_cliente_key (cliente_key),
    KEY idx_fact_ventas_vendedor_key (vendedor_key),
    KEY idx_fact_ventas_producto_key (producto_key),
    KEY idx_fact_ventas_estado_key (estado_key)
);