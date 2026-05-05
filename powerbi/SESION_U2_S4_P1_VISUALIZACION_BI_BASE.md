# Sesión U2 S4 P1: Visualización BI base

## 1. Título

Construcción de una página BI base con KPIs, métricas, filtros y visuales principales.

## 2. Objetivo

Construir una primera página de análisis BI que permita explorar ventas, margen y tiempos operativos usando el modelo semántico creado en Power BI.

Al finalizar la práctica, el alumno debe poder:

- usar medidas DAX en visuales
- analizar métricas por dimensiones
- aplicar filtros y segmentadores
- construir tarjetas KPI
- crear gráficos y matrices base
- validar resultados visuales contra SQL

## 3. Relación con prácticas previas

Esta práctica continúa desde:

1. [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)
2. [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)

## 4. Preguntas de negocio

El reporte debe responder como mínimo:

- cuánto vendió la farmacia
- cuánto margen generó
- qué productos venden más
- qué familias o categorías concentran ventas
- qué clientes compran más
- qué vendedores generan mayor venta
- cómo se comportan las ventas por fecha
- cuánto tarda el proceso operativo de atención

## 5. Visuales mínimos

### 5.1 Tarjetas KPI

Crea tarjetas para:

- `[Ventas Netas]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Pedidos]`
- `[Unidades Vendidas]`

### 5.2 Evolución temporal

Crea un gráfico de líneas:

Eje:

- `dim_fecha[fecha]`

Valores:

- `[Ventas Netas]`
- `[Ventas Netas Acumuladas]`

### 5.3 Matriz por producto

Crea una matriz:

Filas:

- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_producto[nombre_producto]`

Valores:

- `[Ventas Netas]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Unidades Vendidas]`

Uso esperado:

- observar resultados por familia
- bajar a categoría
- revisar producto

El drill-down formal y el drill-through se trabajan en la siguiente sesión.

### 5.4 Ventas por cliente

Crea un gráfico de barras:

Eje:

- `dim_cliente[nombre_cliente]`

Valores:

- `[Ventas Netas]`

Orden:

- descendente por `[Ventas Netas]`

### 5.5 Ventas por vendedor

Crea un gráfico de barras:

Eje:

- `dim_vendedor[nombre_vendedor]`

Valores:

- `[Ventas Netas]`
- `[Pedidos]`

### 5.6 Tiempos operativos

Crea tarjetas o columnas para:

- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Horas Entrega Promedio]`
- `[Horas Lead Time Promedio]`

## 6. Segmentadores recomendados

Agrega segmentadores para:

- `dim_fecha[anio]`
- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_estado_pedido[estado_pedido]`

Estos filtros deben afectar los visuales principales.

## 7. Validación funcional

### 7.1 Validar una tarjeta contra SQL

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

Debe coincidir con la tarjeta `[Ventas Netas]` cuando no hay filtros activos.

### 7.2 Validar ventas por producto contra SQL

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

Debe coincidir con la matriz o gráfico por producto.

### 7.3 Validar que los filtros funcionen

Selecciona una categoría en el segmentador.

Debes observar que cambian:

- tarjetas KPI
- gráfico temporal
- matriz de productos
- gráficos de cliente y vendedor

Si no cambian, revisa relaciones y dirección de filtro.

## 8. Diseño mínimo de página

La página debe priorizar lectura analítica:

- primera fila: tarjetas KPI
- zona central: evolución temporal y matriz por producto
- zona lateral o superior: segmentadores
- zona inferior: cliente, vendedor y tiempos operativos

Evita mezclar demasiados colores. Usa formatos consistentes:

- moneda para ventas y margen
- porcentaje para ratios
- enteros para conteos
- decimales moderados para tiempos

## 9. Evidencias a entregar

- captura de tarjetas KPI
- captura de gráfico temporal
- captura de matriz por producto
- captura de filtros aplicados
- captura de ventas por cliente o vendedor
- captura de validación contra SQL
- archivo `.pbix` guardado en la carpeta `powerbi`

## 10. Cierre

Con esta práctica se construye la primera página BI base. La siguiente sesión profundiza en interactividad avanzada: drill-down, drill-through, tooltips y segmentación.
