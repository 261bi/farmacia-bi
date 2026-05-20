# Sesión U2 S3 P2: Medidas DAX y agregaciones BI v2

## 1. Título

Creación de medidas DAX mínimas para análisis de ventas en Power BI.

## 2. Objetivo

Crear una capa simple de medidas oficiales para analizar ventas netas, pedidos, unidades y ticket promedio.

Al finalizar la práctica, el alumno debe poder:

- diferenciar columnas numéricas de medidas
- clasificar métricas según su forma correcta de agregación
- crear medidas DAX reutilizables
- evitar agregaciones improvisadas en visuales
- usar tarjetas, matrices y gráficos para interpretar las medidas
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

## 5. Tipos de métricas

Antes de crear medidas, define qué tipo de cálculo estás haciendo. No todas las métricas se agregan igual.

### 5.1 Métricas aditivas

Se pueden sumar directamente a través de productos, clientes, meses o años.

Ejemplos:

- ventas netas
- unidades vendidas
- ventas brutas
- descuentos
- costo total
- margen bruto

Ejemplo DAX:

```DAX
Ventas Netas = SUM(fact_ventas[venta_neta])
```

### 5.2 Métricas semi-aditivas o de conteo

No siempre se suman fila por fila, porque pueden repetirse dentro de la tabla de hechos.

Ejemplos:

- pedidos
- clientes atendidos
- productos distintos vendidos

En este modelo, `pedido_id` se repite porque un pedido puede tener varios productos. Por eso no se usa `COUNT`, sino:

```DAX
Pedidos = DISTINCTCOUNT(fact_ventas[pedido_id])
```

### 5.3 Métricas no aditivas

No se deben sumar ni promediar sin revisar la lógica. Normalmente son razones, porcentajes o promedios.

Ejemplos:

- ticket promedio
- porcentaje de margen
- porcentaje de descuento
- precio promedio
- tiempos promedio

Regla clave:

```text
Primero calcula numerador y denominador.
Luego calcula el ratio.
```

Por eso, el ticket promedio se calcula así:

```DAX
Ticket Promedio = DIVIDE([Ventas Netas], [Pedidos])
```

No como suma o promedio directo de una columna.

## 6. Medidas obligatorias

### 6.1 Ventas netas

```DAX
Ventas Netas = SUM(fact_ventas[venta_neta])
```

Es la medida principal del curso.

### 6.2 Pedidos

```DAX
Pedidos = DISTINCTCOUNT(fact_ventas[pedido_id])
```

Se usa `DISTINCTCOUNT` porque un pedido puede tener varias líneas.

### 6.3 Unidades vendidas

```DAX
Unidades Vendidas = SUM(fact_ventas[cantidad_vendida])
```

### 6.4 Ticket promedio

```DAX
Ticket Promedio = DIVIDE([Ventas Netas], [Pedidos])
```

## 7. Uso inmediato de las medidas

Crea una página temporal llamada:

```text
Prueba de medidas
```

### 7.1 Tarjetas principales

Agrega tres tarjetas:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Ticket Promedio]`

Resultado esperado:

- ventas netas responde al total vendido
- pedidos cuenta pedidos únicos, no líneas
- ticket promedio cambia cuando filtras por año, categoría o cliente

### 7.2 Matriz por categoría

Agrega una `Matriz`.

Filas:

- `dim_producto[nombre_categoria]`

Valores:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`

Pregunta:

```text
¿La categoría con más ventas siempre tiene el mayor ticket promedio?
```

La respuesta puede ser no. Una categoría puede vender mucho por volumen, pero tener menor venta promedio por pedido.

### 7.3 Gráfico por mes

Agrega un `Gráfico de columnas agrupadas`.

Eje X:

- `dim_fecha[mes_desc]`

Valores:

- `[Ventas Netas]`

Segmentador:

- `dim_fecha[anio]`

Resultado esperado:

- los meses respetan el orden calendario
- al seleccionar 2026, solo aparecen meses hasta mayo
- el gráfico ayuda a detectar que 2026 es un año parcial

## 8. Medidas opcionales

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

Nota:

```text
% Margen Bruto se calcula con medidas, no promediando fact_ventas[pct_margen_bruto].
```

## 9. Medidas operativas opcionales

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

Estas medidas son promedios operativos. Úsalas solo si el análisis incluye tiempos de atención, despacho o entrega.

## 10. Medida temporal simple

```DAX
Ventas Netas Acumuladas =
CALCULATE(
    [Ventas Netas],
    FILTER(
        ALLSELECTED(dim_fecha),
        dim_fecha[fecha] <= MAX(dim_fecha[fecha])
    )
)
```

No se usarán funciones de inteligencia de tiempo como ruta principal. El curso trabajará con `dim_fecha`.

### 10.1 Cómo leer esta medida

`CALCULATE` cambia el contexto de filtro para volver a calcular `[Ventas Netas]`.

`FILTER` construye una tabla de fechas permitidas.

Esta parte:

```DAX
dim_fecha[fecha] <= MAX(dim_fecha[fecha])
```

significa:

```text
Toma todas las fechas visibles hasta la fecha actual del punto evaluado.
```

`ALLSELECTED(dim_fecha)` quita los filtros internos que genera el visual sobre la tabla de fechas, por ejemplo el mes del eje, pero respeta lo que el usuario seleccionó en segmentadores o filtros externos.

Si se usa solo `ALLSELECTED(dim_fecha[fecha])`, el filtro de `mes_desc` puede seguir activo. En ese caso la medida acumula solo dentro del mes actual y termina mostrando el mismo valor que `[Ventas Netas]`.

Ejemplos:

- si seleccionas `2025`, el acumulado corre dentro de 2025
- si seleccionas `2026`, el acumulado llega solo hasta mayo porque no hay fechas posteriores
- si no seleccionas año, el acumulado considera todas las fechas visibles del reporte

### 10.2 Prueba visual de la acumulada

Agrega un `Gráfico de líneas`.

Eje X:

- `dim_fecha[mes_desc]`

Valores:

- `[Ventas Netas]`
- `[Ventas Netas Acumuladas]`

Segmentador:

- `dim_fecha[anio]`

Selecciona un solo año para esta primera lectura.

Resultado esperado:

- `[Ventas Netas]` muestra el valor de cada mes
- `[Ventas Netas Acumuladas]` va sumando mes a mes
- en 2026 la línea acumulada se detiene en mayo

Nota:

```text
Para explicar la acumulada por primera vez, usa un segmentador de año. La comparación acumulada entre varios años se trabajará después como KPI comparativo.
```

Pregunta:

```text
¿Por qué el acumulado no llega a diciembre de 2026?
```

Respuesta esperada:

```text
Porque el modelo solo tiene datos hasta el 20/05/2026. La medida no inventa meses futuros.
```

## 11. Formatos de medidas

Aplica a las medidas el criterio de formato definido en la P1 del modelo semántico:

- moneda: `[Ventas Netas]`, `[Ticket Promedio]`
- entero: `[Pedidos]`, `[Unidades Vendidas]`
- moneda opcional: `[Ventas Brutas]`, `[Descuentos]`, `[Costo Total]`, `[Margen Bruto]`
- porcentaje opcional: `[% Margen Bruto]`

La regla nace en el modelo semántico; aquí solo se aplica a las medidas recién creadas.

## 12. Validación SQL

### 12.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

### 12.2 Pedidos

```sql
SELECT COUNT(DISTINCT pedido_id) AS pedidos
FROM marts.fact_ventas;
```

### 12.3 Unidades vendidas

```sql
SELECT SUM(cantidad_vendida) AS unidades_vendidas
FROM marts.fact_ventas;
```

### 12.4 Ticket promedio

```sql
SELECT
    SUM(venta_neta) / NULLIF(COUNT(DISTINCT pedido_id), 0) AS ticket_promedio
FROM marts.fact_ventas;
```

## 13. Validación visual final

Antes de cerrar, verifica que las medidas funcionen en distintos niveles del modelo:

- tarjetas con `[Ventas Netas]`, `[Pedidos]` y `[Ticket Promedio]`
- matriz por `dim_producto[nombre_categoria]` con las medidas obligatorias
- gráfico por `dim_fecha[mes_desc]` con `[Ventas Netas]`
- gráfico de líneas con `[Ventas Netas]` y `[Ventas Netas Acumuladas]`
- segmentador por `dim_fecha[anio]`

Resultado esperado:

- las tarjetas cambian al filtrar por año
- la matriz permite comparar categorías
- el gráfico mensual muestra 2026 como periodo parcial
- la acumulada responde al filtro seleccionado

## 14. Evidencias a entregar

- captura de tabla `_Medidas`
- captura de medidas obligatorias
- captura de formatos aplicados
- captura de tarjetas principales
- captura de matriz por categoría
- captura de gráfico mensual
- captura de gráfico acumulado
- captura de validación SQL

## 15. Cierre

Con esta práctica, el modelo ya tiene una capa mínima de métricas gobernadas. Las siguientes sesiones usarán estas medidas para explorar, contar hallazgos y construir KPIs ejecutivos.
