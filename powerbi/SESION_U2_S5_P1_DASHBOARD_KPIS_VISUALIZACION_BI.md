# Sesión U2 S5 P1: Dashboard BI con KPIs base

## 1. Título

Construcción de una página ejecutiva de Power BI con KPIs comerciales base.

## 2. Objetivo

Construir una página `Resumen BI` que comunique ventas netas, pedidos, unidades, ticket promedio y principales dimensiones de análisis.

Al finalizar la práctica, el alumno debe poder:

- seleccionar KPIs base
- diseñar una página ejecutiva simple
- usar medidas DAX en todos los visuales
- crear visuales de tendencia, producto, cliente y vendedor
- aplicar segmentadores útiles para negocio
- mantener formatos consistentes
- validar KPIs contra SQL

## 3. Relación con prácticas previas

Esta práctica continúa desde:

- [SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md](SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md)

La S4 permitió explorar. La S5 decide qué mostrar primero y cómo presentarlo.

## 4. Medidas principales

Medidas obligatorias:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`

Medidas opcionales:

- `[Ventas Brutas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`

Medidas operativas opcionales:

- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Horas Entrega Promedio]`
- `[Horas Lead Time Promedio]`

## 5. Preguntas de negocio

La página debe responder:

- ¿cuánto vendió la farmacia?
- ¿cuántos pedidos atendió?
- ¿cuántas unidades vendió?
- ¿cuál es el ticket promedio?
- ¿qué productos explican la venta?
- ¿qué clientes concentran compras?
- ¿qué vendedores generan mayor venta?
- ¿cómo evolucionan las ventas?

Opcional:

- ¿cuánto margen generó?
- ¿cuánto descuento otorgó?
- ¿dónde aparece mayor demora operativa?

## 6. Regla de construcción

Los visuales deben usar medidas DAX.

```text
dimensiones -> ejes, filas, columnas y filtros
medidas DAX -> valores y KPIs
```

## 7. Página `Resumen BI`

Crea una página llamada:

```text
Resumen BI
```

Estructura sugerida:

```text
Fila superior: filtros principales
Fila 1: KPIs base
Centro: tendencia temporal + producto
Base: clientes + vendedores
Opcional: bloque operativo
```

## 8. Tarjetas KPI base

Crea tarjetas para:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`

Formato:

- moneda: ventas y ticket
- entero: pedidos y unidades

Opcional:

- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Descuentos]`

## 9. Visual temporal

Crea un gráfico de líneas.

Eje:

- `dim_fecha[fecha]` o jerarquía `Calendario`

Valores:

- `[Ventas Netas]`

Opcional:

- `[Ventas Netas Acumuladas]`

Uso:

- mostrar tendencia
- detectar picos o caídas
- conectar la lectura temporal con filtros

## 10. Visual de producto

Usa una matriz o gráfico de barras.

Filas o eje:

- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_producto[nombre_producto]`

Valores:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`

Opcional:

- `[Margen Bruto]`
- `[% Margen Bruto]`

## 11. Ranking de clientes

Crea un gráfico de barras.

Eje:

- `dim_cliente[nombre_cliente]`

Valores:

- `[Ventas Netas]`

Tooltip:

- `[Ticket Promedio]`
- `[Pedidos]`

Aplica Top N de 10 clientes.

## 12. Ranking de vendedores

Crea un gráfico de barras.

Eje:

- `dim_vendedor[nombre_vendedor]`

Valores:

- `[Ventas Netas]`

Tooltip:

- `[Pedidos]`
- `[Ticket Promedio]`

## 13. Bloque operativo opcional

Si ya se completó el dashboard comercial, agrega:

- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Horas Entrega Promedio]`
- `[Horas Lead Time Promedio]`

Estas métricas son promedios. No deben mostrarse como suma.

## 14. Segmentadores del dashboard

Agrega filtros visibles:

- `dim_fecha[anio]`
- `dim_fecha[mes_desc]`
- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_estado_pedido[estado_pedido]`

Regla:

- el usuario debe entender el filtro sin conocer el modelo físico
- no uses claves técnicas como segmentadores

## 15. Diseño mínimo

Buenas prácticas:

- KPIs arriba
- títulos claros
- pocos colores y con intención
- visuales alineados
- rankings limitados
- formatos consistentes
- no repetir el mismo indicador sin necesidad

## 16. Validación SQL

### 16.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

### 16.2 Pedidos

```sql
SELECT COUNT(DISTINCT pedido_id) AS pedidos
FROM marts.fact_ventas;
```

### 16.3 Unidades vendidas

```sql
SELECT SUM(cantidad_vendida) AS unidades_vendidas
FROM marts.fact_ventas;
```

### 16.4 Ticket promedio

```sql
SELECT
    SUM(venta_neta) / NULLIF(COUNT(DISTINCT pedido_id), 0) AS ticket_promedio
FROM marts.fact_ventas;
```

## 17. Checklist

- existe página `Resumen BI`
- los KPIs base usan medidas DAX
- los formatos son correctos
- existe visual temporal
- existe visual de producto
- existe ranking de clientes
- existe ranking de vendedores
- los segmentadores afectan los visuales principales
- los KPIs base coinciden contra SQL
- la página se entiende como resumen ejecutivo

## 18. Evidencias a entregar

- captura de KPIs base
- captura del visual temporal
- captura de producto
- captura de ranking de clientes
- captura de ranking de vendedores
- captura con filtros aplicados
- captura de validación SQL

Nombre sugerido:

```text
FarmaciaPBI_U2_S5_P1_Dashboard_KPIs_Base.pbix
```

## 19. Cierre

Con esta práctica, los hallazgos exploratorios se convierten en una página ejecutiva. La siguiente práctica agrega KPIs comparativos, variación e iconos.
