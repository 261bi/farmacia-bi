# Sesión U2 S1 P1: Implementación física manual del DataMart dentro del mismo OLTP

## 1. Título

Implementación física manual del DataMart del caso `farmadb` dentro del mismo motor MySQL transaccional.

## 2. Propósito de la sesión

En esta práctica el estudiante no usará todavía Airbyte ni dbt. Primero construirá manualmente la estructura física del DataMart directamente en la misma base `farmadb`, para entender cómo se implementa un modelo analítico con SQL antes de pasar a herramientas especializadas.

Esta sesión se concentra solo en la parte física:

- revisar el OLTP real
- identificar las tablas fuente
- definir el modelo estrella que se implementará
- crear manualmente las dimensiones
- crear manualmente la tabla de hechos
- dejar lista la estructura para la sesión siguiente, donde se hará el ETL manual

## 3. Caso de negocio oficial

Caso práctico del curso:

**Análisis comercial y operativo del ciclo de pedidos de una distribuidora farmacéutica usando `farmadb`.**

## 4. Problema de negocio

La empresa registra pedidos y productos vendidos en una base transaccional, pero la información está distribuida entre cabecera del pedido, detalle, cliente, vendedor, producto, categoría y familia. Esto dificulta evaluar de manera integrada el desempeño comercial y la eficiencia operativa del proceso de atención del pedido.

En consecuencia, la gerencia no puede responder con rapidez preguntas como:

- cuánto se vende
- qué productos o categorías generan mayor ingreso y margen
- qué vendedor o cliente concentra mayor actividad
- cuánto descuento se otorga
- cuánto tarda un pedido en ser confirmado, despachado y entregado

## 5. Área o proceso involucrado

Proceso principal:

**Gestión de pedidos y ventas**

Esto se sustenta en la relación entre:

- `pedidos`
- `pedido_detalles`

junto con las entidades de contexto:

- `clientes`
- `vendedores`
- `productos`
- `categorias`
- `familias`

## 6. Objetivo analítico

Diseñar e implementar físicamente un DataMart que permita analizar el desempeño comercial y operativo del proceso de pedidos, integrando métricas de ventas, cantidades, descuentos, margen bruto y tiempos del ciclo del pedido.

## 7. Punto de partida real: el OLTP `farmadb`

La base transaccional real se encuentra en:

- [farmadb.sql](/c:/261bi/farmacia-bi/oltp-mysql/mysql/init/farmadb.sql)

En esa base existen las tablas fuente:

- `familias`
- `categorias`
- `productos`
- `clientes`
- `vendedores`
- `pedidos`
- `pedido_detalles`

## 8. Recordatorio importante de diseño

En la Unidad 1 ya se realizó el modelado dimensional conceptual en papel. En esta sesión no se vuelve a diseñar desde cero. Aquí se toma ese diseño aprobado y se lo convierte en estructuras físicas reales en MySQL.

## 9. Preguntas analíticas congeladas

Estas serán las preguntas oficiales del caso:

- ¿Cuál es el monto total vendido por día, mes y año?
- ¿Cuántas unidades se venden por producto, categoría y familia?
- ¿Qué productos generan mayor venta neta?
- ¿Qué productos, categorías y familias generan mayor margen bruto?
- ¿Qué clientes registran mayor volumen de compra y mayor ticket promedio?
- ¿Qué vendedores generan mayores ventas y mejor margen?
- ¿Cuánto descuento total se otorga por producto, cliente y vendedor?
- ¿Cuánto tiempo tarda un pedido en ser confirmado?
- ¿Cuánto tiempo tarda un pedido en ser despachado?
- ¿Cuánto tiempo tarda un pedido en ser entregado?
- ¿Cuál es el lead time total del pedido desde creación hasta entrega?
- ¿Qué porcentaje de pedidos se entrega dentro del tiempo objetivo definido?
- ¿Qué etapa del proceso concentra mayor demora: confirmación, despacho o entrega?

Estas preguntas son viables porque la base contiene medidas monetarias y de cantidad en `pedido_detalles`, el estado y las fechas del flujo en `pedidos`, y la clasificación comercial vía `productos -> categorias -> familias`.

## 10. KPIs congelados

### A. KPIs comerciales

**KPI 1. Ventas netas**

- Definición: monto total vendido después de descuentos.
- Fórmula base: suma de ventas netas por línea de pedido.
- Fuente: `pedido_detalles`.

**KPI 2. Unidades vendidas**

- Definición: total de unidades vendidas.
- Fórmula base: suma de `cantidad`.
- Fuente: `pedido_detalles`.

**KPI 3. Margen bruto**

- Definición: diferencia entre venta neta y costo total.
- Fuente: `pedido_detalles`, usando precio de venta, precio de compra, descuento y cantidad.

**KPI 4. % Margen bruto**

- Definición: proporción del margen bruto respecto de la venta neta.
- Fuente: derivado desde las medidas de detalle.

**KPI 5. Ticket promedio por pedido**

- Definición: venta neta promedio por pedido.
- Fuente: `pedidos` + `pedido_detalles`.

**KPI 6. Descuento total otorgado**

- Definición: monto total de descuento aplicado en las líneas del pedido.
- Fuente: `pedido_detalles`.

### B. KPIs operativos del proceso

**KPI 7. Tiempo de confirmación (minutos)**

- Definición: tiempo entre creación y confirmación del pedido.
- Base temporal: `fecha_creacion -> fecha_confirmacion` en `pedidos`.

**KPI 8. Tiempo de despacho (minutos)**

- Definición: tiempo entre confirmación y envío.
- Base temporal: `fecha_confirmacion -> fecha_envio` en `pedidos`.

**KPI 9. Tiempo de entrega (horas)**

- Definición: tiempo entre envío y entrega.
- Base temporal: `fecha_envio -> fecha_entrega` en `pedidos`.

**KPI 10. Lead time del pedido (horas)**

- Definición: tiempo total del pedido desde creación hasta entrega.
- Base temporal: `fecha_creacion -> fecha_entrega` en `pedidos`.
- Este será el KPI rey del proceso.

**KPI 11. % Pedidos entregados a tiempo**

- Definición: porcentaje de pedidos cuyo lead time está dentro del SLA definido por el negocio.
- Fuente: derivado desde las fechas del pedido.

**KPI 12. Cantidad de pedidos**

- Definición: número de pedidos registrados.
- Fuente: `pedidos`.

## 11. KPIs que quedan fuera

Para mantener trazabilidad y coherencia con la fuente, no se incluirán KPIs de:

- stock
- rotación de inventario
- compras
- proveedores
- quiebres
- abastecimiento
- devoluciones
- metas o presupuesto

El alcance oficial queda restringido a ventas y ciclo de pedidos.

## 12. Granularidad congelada

El grano congelado del hecho será:

**una fila por línea de pedido por producto**

Esto es coherente porque el detalle transaccional está en `pedido_detalles`, vinculado al pedido y al producto, y desde ahí se derivan las medidas comerciales, mientras que las fechas operativas vienen de `pedidos`.

### Aclaración con ejemplo

Supón que en `pedido_detalles` existen estas filas:

| pedido_id | producto_id | cliente_id | vendedor_id | fecha | cantidad |
|---|---:|---:|---:|---|---:|
| 1 | 10 | 1 | 1 | 2020-03-08 | 5 |
| 2 | 10 | 1 | 1 | 2020-03-08 | 3 |
| 3 | 20 | 1 | 1 | 2020-03-08 | 7 |

Si agrupamos por:

- fecha
- producto
- cliente
- vendedor

entonces las dos primeras filas se consolidan en una sola, porque comparten:

- misma fecha
- mismo producto
- mismo cliente
- mismo vendedor

El resultado agregado sería algo así:

| fecha | producto_id | cliente_id | vendedor_id | cantidad_total |
|---|---:|---:|---:|---:|
| 2020-03-08 | 10 | 1 | 1 | 8 |
| 2020-03-08 | 20 | 1 | 1 | 7 |

Aquí ya no tenemos una fila por línea de pedido por producto. Ahora tenemos una fila resumida por combinación de dimensiones.

Si en cambio respetamos el grano oficial del curso, entonces el hecho debe conservar el detalle transaccional así:

| pedido_id | producto_id | cliente_id | vendedor_id | fecha | cantidad |
|---|---:|---:|---:|---|---:|
| 1 | 10 | 1 | 1 | 2020-03-08 | 5 |
| 2 | 10 | 1 | 1 | 2020-03-08 | 3 |
| 3 | 20 | 1 | 1 | 2020-03-08 | 7 |

### Conclusión del ejemplo

- el primer caso crea una tabla resumen
- el segundo caso conserva el detalle transaccional
- para este curso, `fact_ventas` debe respetar el segundo enfoque

En otras palabras, la unidad de negocio de cada fila no será una agregación por fecha, cliente, vendedor y producto, sino la línea del pedido representada en la fuente por `pedido_id + producto_id`.

## 13. Tabla de hechos congelada

`fact_ventas`

Será la tabla de hechos central del caso. Contendrá medidas comerciales y operativas derivadas del pedido y su detalle.

Medidas congeladas:

- `cantidad_vendida`
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
- `pedido_count`

## 14. Dimensiones congeladas

Para esta versión final del curso, el esquema estrella queda congelado con estas dimensiones:

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`

Y con una tabla de hechos central:

- `fact_ventas`

### Origen de las dimensiones

`dim_cliente`

- desde `clientes`
- campos base esperados:
  - `cliente_id`
  - `nombre`

`dim_vendedor`

- desde `vendedores`
- campos base esperados:
  - `vendedor_id`
  - `nombre`

`dim_producto`

- desde `productos`
- desde `categorias`
- desde `familias`
- esta dimensión concentra la jerarquía comercial completa del producto
- campos base esperados:
  - `producto_id`
  - `codigo`
  - `nombre_producto`
  - `concentracion`
  - `presentacion`
  - `fracciones`
  - `categoria_id`
  - `categoria_nombre`
  - `familia_id`
  - `familia_nombre`

`dim_fecha`

- derivada de `pedidos.fecha_creacion` como fecha principal
- campos base esperados:
  - `fecha`
  - `dia`
  - `mes`
  - `trimestre`
  - `anio`
- inicialmente se usará `fecha_creacion` como fecha analítica principal
- más adelante, si se requiere, podrán manejarse roles de fecha para confirmación, envío y entrega

`dim_estado_pedido`

- desde `pedidos.estado`
- campos base esperados:
  - `estado_pedido`

### Decisión de diseño congelada

No se crearán `dim_categoria` ni `dim_familia` como dimensiones separadas.

La implementación final del curso trabajará con una sola `dim_producto`, la cual quedará **denormalizada** e incorporará también los atributos de categoría y familia.

Esto mantiene una estrella más limpia, más simple y más consistente con el alcance analítico del caso.

## 15. Jerarquías congeladas

### Tiempo

- Día -> Mes -> Trimestre -> Año

### Producto comercial

- Familia -> Categoría -> Producto

En la implementación física, la segunda jerarquía quedará materializada dentro de `dim_producto`.

## 16. Mapeo OLTP -> modelo dimensional congelado

### Hecho principal

Origen de `fact_ventas`

- Base principal: `pedido_detalles`
- Complemento: `pedidos`

### Reglas de integración

- `pedido_detalles.pedido_id` enlaza con `pedidos.id`
- `pedidos.cliente_id` aporta cliente
- `pedidos.vendedor_id` aporta vendedor
- `pedidos.fecha_creacion`, `fecha_confirmacion`, `fecha_envio`, `fecha_entrega` aportan métricas de proceso
- `pedidos.estado` aporta estado del pedido
- `pedido_detalles.producto_id` aporta producto
- `productos.categoria_id` enlaza con `categorias.id`
- `categorias.familia_id` enlaza con `familias.id`

### Campos de negocio mapeados

- cantidad vendida <- `pedido_detalles.cantidad`
- precio venta unitario <- `pedido_detalles.precio_venta_unitario`
- precio compra unitario <- `pedido_detalles.precio_compra_unitario`
- descuento <- `pedido_detalles.total_descuento_unitario`
- fechas operativas <- `pedidos`
- estado <- `pedidos.estado`

### Construcción de dimensiones

- `dim_cliente` <- `clientes`
- `dim_vendedor` <- `vendedores`
- `dim_producto` <- `productos + categorias + familias`
- `dim_estado_pedido` <- `pedidos.estado`
- `dim_fecha` <- derivada de `pedidos.fecha_creacion`

## 17. Matriz BUS congelada

Solo habrá un proceso fuerte, para no inventar procesos que el esquema no soporta.

| Proceso | Métricas | Dimensiones |
|---|---|---|
| Pedidos / Ventas | ventas netas, unidades vendidas, margen bruto, % margen, ticket promedio, descuento total, tiempo de confirmación, tiempo de despacho, tiempo de entrega, lead time | fecha, cliente, vendedor, producto, estado del pedido |

## 18. Validación congelada

**¿Los KPIs responden al problema?**

Sí. El problema es comercial y operativo, y los KPIs cubren ventas, rentabilidad y eficiencia del ciclo del pedido.

**¿El modelo soporta el análisis?**

Sí. El grano por línea de pedido permite analizar ventas y margen por producto, cliente y vendedor, y además cruzar eso con tiempos del proceso tomados desde `pedidos`.

**¿Las fuentes son suficientes?**

Sí, para este alcance de pedidos/ventas. No para inventario ni abastecimiento.

## 19. Versión final congelada para el curso

### Alcance oficial

DataMart de ventas y ciclo de pedidos

### Arquitectura oficial

MySQL (`farmadb`) -> Airbyte -> PostgreSQL `raw` -> dbt -> DataMart -> Power BI

### KPI rey

Lead time del pedido

### Hecho principal

`fact_ventas`

### Esquema dimensional final

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`
- `fact_ventas`

### Nota de actualización técnica

El esquema transaccional fue normalizado en nombres, por lo que ahora usa tablas en plural y columnas en `snake_case`. Además, se incorporaron los campos `fecha_creacion` y `fecha_modificacion`, sin alterar el alcance analítico definido.

## 20. Estructura física que se construirá

### 20.1 `dim_cliente`

Representa al cliente que realiza el pedido.

Campos esperados:

- clave sustituta de dimensión
- identificador de negocio del cliente
- nombre del cliente

### 20.2 `dim_vendedor`

Representa al vendedor asociado al pedido.

Campos esperados:

- clave sustituta de dimensión
- identificador de negocio del vendedor
- nombre del vendedor

### 20.3 `dim_producto`

Representa al producto comercial y también contiene los atributos denormalizados de clasificación.

Campos esperados:

- clave sustituta de dimensión
- identificador de negocio del producto
- código del producto
- nombre comercial del producto
- precio de compra
- precio de venta
- identificador y nombre de categoría
- identificador y nombre de familia

### 20.4 `dim_fecha`

Representa la fecha analítica principal del pedido. Para esta versión se tomará inicialmente la `fecha_creacion` del pedido.

Campos esperados:

- clave de fecha
- fecha completa
- día
- nombre del día
- mes
- nombre del mes
- trimestre
- año

### 20.5 `dim_estado_pedido`

Representa el estado del pedido tomado desde `pedidos.estado`.

Campos esperados:

- clave sustituta del estado
- nombre del estado

### 20.6 `fact_ventas`

Tabla de hechos central del caso.

Medidas congeladas:

- `cantidad_vendida`
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
- `pedido_count`

## 21. Relación entre el OLTP y el DataMart

### Fuentes principales

- `pedido_detalles` aporta el detalle de cantidad, precios y descuentos
- `pedidos` aporta cliente, vendedor, estado y fechas del proceso
- `productos` aporta el producto
- `categorias` y `familias` aportan la clasificación comercial del producto

### Reglas de integración base

- `pedido_detalles.pedido_id` enlaza con `pedidos.id`
- `pedidos.cliente_id` enlaza con `clientes.id`
- `pedidos.vendedor_id` enlaza con `vendedores.id`
- `pedido_detalles.producto_id` enlaza con `productos.id`
- `productos.categoria_id` enlaza con `categorias.id`
- `categorias.familia_id` enlaza con `familias.id`

## 22. Decisión técnica de esta práctica

En esta sesión el DataMart se construirá **dentro de la misma base `farmadb`**.

Esto no es la arquitectura final recomendada, pero sí es una excelente estrategia pedagógica para que el estudiante comprenda:

- cómo se crean manualmente las tablas dimensionales
- cómo se diseña físicamente una tabla de hechos
- cómo se pasa desde OLTP hacia análisis

Más adelante, en la siguiente sesión macro, el DW se separará hacia PostgreSQL y se trabajará con herramientas.

## 23. Preparación del entorno

Levanta el MySQL del laboratorio:

```powershell
cd C:\261bi\farmacia-bi\oltp-mysql
docker compose up -d
docker compose ps
```

Ingresa al motor:

```powershell
docker exec -it farmacia-oltp-mysql mysql -u root -p root farmadb
```

Valida las tablas transaccionales:

```sql
SHOW TABLES;
DESCRIBE clientes;
DESCRIBE vendedores;
DESCRIBE categorias;
DESCRIBE productos;
DESCRIBE pedidos;
DESCRIBE pedido_detalles;
```

## 24. Implementación física manual del DataMart

### 17.1 Crear `dim_cliente`

```sql
CREATE TABLE IF NOT EXISTS dim_cliente (
    cliente_key INT AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    PRIMARY KEY (cliente_key),
    UNIQUE KEY uk_dim_cliente_id (cliente_id)
);
```

### 17.2 Crear `dim_vendedor`

```sql
CREATE TABLE IF NOT EXISTS dim_vendedor (
    vendedor_key INT AUTO_INCREMENT,
    vendedor_id INT NOT NULL,
    nombre_vendedor VARCHAR(100) NOT NULL,
    PRIMARY KEY (vendedor_key),
    UNIQUE KEY uk_dim_vendedor_id (vendedor_id)
);
```

### 17.3 Crear `dim_producto`

```sql
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
```

### 17.4 Crear `dim_fecha`

```sql
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
```

### 17.5 Crear `dim_estado_pedido`

```sql
CREATE TABLE IF NOT EXISTS dim_estado_pedido (
    estado_key INT AUTO_INCREMENT,
    estado_pedido VARCHAR(20) NOT NULL,
    PRIMARY KEY (estado_key),
    UNIQUE KEY uk_dim_estado_pedido (estado_pedido)
);
```

### 17.6 Crear `fact_ventas`

```sql
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
```

## 25. Validación de la estructura creada

Lista las nuevas tablas:

```sql
SHOW TABLES LIKE 'dim_%';
SHOW TABLES LIKE 'fact_%';
```

Revisa su estructura:

```sql
DESCRIBE dim_cliente;
DESCRIBE dim_vendedor;
DESCRIBE dim_producto;
DESCRIBE dim_fecha;
DESCRIBE dim_estado_pedido;
DESCRIBE fact_ventas;
```

## 26. Qué debe quedar listo al cerrar esta sesión

Al terminar esta práctica todavía no deberías haber cargado datos del DataMart. Lo que debe quedar listo es:

- las tablas dimensionales creadas
- la tabla de hechos creada
- la estructura estrella implementada físicamente en MySQL
- el entorno listo para la siguiente sesión, donde se poblarán dimensiones y hecho con SQL

## 27. Qué viene en la siguiente práctica

En la siguiente sesión se trabajará:

- el ETL manual con SQL
- la construcción de dimensiones con `INSERT INTO ... SELECT ...`
- la integración de fuentes mediante la vista `G`
- la posterior carga de `fact_ventas`

## 28. Evidencias a entregar

- captura de `SHOW TABLES` mostrando tablas OLTP y tablas `dim_*` / `fact_*`
- captura de `DESCRIBE dim_producto`
- captura de `DESCRIBE fact_ventas`
- breve explicación de por qué `dim_producto` queda denormalizada

## 29. Cierre

En esta sesión se construyó manualmente la base física del DataMart dentro del mismo OLTP. Esta decisión permite entender con claridad cómo se implementa un esquema estrella desde SQL puro, antes de pasar a un pipeline más moderno con Airbyte, PostgreSQL y dbt.
