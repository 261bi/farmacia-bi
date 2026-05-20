# Sesión U2 S3 P2: Medidas DAX y agregaciones BI v2

## 1. Título

Creación de medidas DAX mínimas para análisis de ventas en Power BI.

## 2. Objetivo

Crear una capa simple de medidas oficiales para analizar ventas netas, pedidos, unidades y ticket promedio.

Al finalizar la práctica, el alumno debe poder:

- diferenciar columnas numéricas de medidas
- crear medidas DAX reutilizables
- evitar agregaciones improvisadas en visuales
- validar medidas principales contra SQL
- usar medidas en tablas, matrices y visuales temporales

## 3. Regla central

En Power BI:

```text
dimensiones -> filtros, filas, columnas y ejes
medidas     -> valores del análisis
```

El alumno no debe arrastrar columnas numéricas de `fact_ventas` como si fueran KPIs finales. Primero se crean medidas oficiales.

## 4. Tabla de medidas

Crea una tabla vacía llamada:

```text
_Medidas
```

Usa esta tabla para guardar todas las medidas DAX del reporte.

## 5. Medidas obligatorias

### 5.1 Ventas netas

```DAX
Ventas Netas = SUM(fact_ventas[venta_neta])
```

Es la medida principal del curso.

### 5.2 Pedidos

```DAX
Pedidos = DISTINCTCOUNT(fact_ventas[pedido_id])
```

Se usa `DISTINCTCOUNT` porque un pedido puede tener varias líneas.

### 5.3 Unidades vendidas

```DAX
Unidades Vendidas = SUM(fact_ventas[cantidad_vendida])
```

### 5.4 Ticket promedio

```DAX
Ticket Promedio = DIVIDE([Ventas Netas], [Pedidos])
```

## 6. Medidas opcionales

Estas medidas se pueden crear si el grupo ya domina la lectura básica de ventas.

```DAX
Ventas Brutas = SUM(fact_ventas[venta_bruta])
```

```DAX
Descuentos = SUM(fact_ventas[descuento_total])
```

```DAX
Costo Total = SUM(fact_ventas[costo_total])
```

```DAX
Margen Bruto = SUM(fact_ventas[margen_bruto])
```

```DAX
% Margen Bruto = DIVIDE([Margen Bruto], [Ventas Netas])
```

## 7. Medidas operativas opcionales

```DAX
Minutos Confirmación Promedio = AVERAGE(fact_ventas[minutos_confirmacion])
```

```DAX
Minutos Despacho Promedio = AVERAGE(fact_ventas[minutos_despacho])
```

```DAX
Horas Entrega Promedio = AVERAGE(fact_ventas[horas_entrega])
```

```DAX
Horas Lead Time Promedio = AVERAGE(fact_ventas[horas_lead_time])
```

## 8. Medida temporal simple

```DAX
Ventas Netas Acumuladas =
CALCULATE(
    [Ventas Netas],
    FILTER(
        ALLSELECTED(dim_fecha[fecha]),
        dim_fecha[fecha] <= MAX(dim_fecha[fecha])
    )
)
```

No se usarán funciones de inteligencia de tiempo como ruta principal. El curso trabajará con `dim_fecha`.

## 9. Formatos

Configura:

- moneda: `[Ventas Netas]`, `[Ticket Promedio]`
- entero: `[Pedidos]`, `[Unidades Vendidas]`
- moneda opcional: `[Ventas Brutas]`, `[Descuentos]`, `[Costo Total]`, `[Margen Bruto]`
- porcentaje opcional: `[% Margen Bruto]`

## 10. Validación SQL

### 10.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

### 10.2 Pedidos

```sql
SELECT COUNT(DISTINCT pedido_id) AS pedidos
FROM marts.fact_ventas;
```

### 10.3 Unidades vendidas

```sql
SELECT SUM(cantidad_vendida) AS unidades_vendidas
FROM marts.fact_ventas;
```

### 10.4 Ticket promedio

```sql
SELECT
    SUM(venta_neta) / NULLIF(COUNT(DISTINCT pedido_id), 0) AS ticket_promedio
FROM marts.fact_ventas;
```

## 11. Validación visual

Crea:

- una tarjeta con `[Ventas Netas]`
- una tarjeta con `[Pedidos]`
- una tarjeta con `[Ticket Promedio]`
- una matriz por `dim_producto[nombre_categoria]` con `[Ventas Netas]`
- un gráfico por `dim_fecha[mes_desc]` con `[Ventas Netas]`

## 12. Evidencias a entregar

- captura de tabla `_Medidas`
- captura de medidas obligatorias
- captura de formatos aplicados
- captura de tarjetas principales
- captura de validación SQL

## 13. Cierre

Con esta práctica, el modelo ya tiene una capa mínima de métricas gobernadas. Las siguientes sesiones usarán estas medidas para explorar, contar hallazgos y construir KPIs ejecutivos.
