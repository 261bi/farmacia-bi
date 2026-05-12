# Sesión U2 S4 P1: Visualización BI base

## 1. Título

Construcción de una página BI base con KPIs, métricas, filtros y visuales principales.

## 2. Objetivo

Construir una primera página de análisis BI que permita explorar ventas, margen, descuentos, clientes, vendedores y tiempos operativos usando el modelo semántico creado en Power BI.

Al finalizar la práctica, el alumno debe poder:

- usar medidas DAX en visuales
- analizar métricas por dimensiones
- aplicar filtros y segmentadores
- construir tarjetas KPI
- crear gráficos y matrices base
- comparar desempeño comercial y operativo en la misma página
- controlar formatos visuales básicos
- validar resultados visuales contra SQL

## 3. Relación con prácticas previas

Esta práctica continúa desde:

1. [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)
2. [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)

Antes de iniciar, verifica que el archivo `.pbix` tenga:

- las seis tablas del schema `marts`
- relaciones activas entre dimensiones y `fact_ventas`
- jerarquía `Calendario`
- jerarquía `Producto Comercial`
- tabla `_Medidas`
- medidas DAX principales creadas y formateadas

## 4. Punto de partida

Abre el archivo Power BI trabajado en la sesión anterior.

El modelo debe contener estas tablas:

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`
- `fact_ventas`

Y estas medidas como mínimo:

- `[Ventas Netas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[% Descuento]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ventas Netas Acumuladas]`
- `[Ticket Promedio]`
- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Horas Entrega Promedio]`
- `[Horas Lead Time Promedio]`

## 4.1 Medidas complementarias para esta práctica

La sesión anterior ya dejó una base de medidas entregada y no debe modificarse. Para completar la visualización base con todos los KPIs del caso, en esta práctica agrega además estas medidas dentro de `_Medidas`.

### A. Porcentaje de pedidos entregados a tiempo

Para mantener consistencia con la validación analítica manual del caso, usa:

- `SLA = 24 horas`

```DAX
% Pedidos a Tiempo =
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(fact_ventas[pedido_id]),
        FILTER(
            fact_ventas,
            NOT ISBLANK(fact_ventas[horas_lead_time])
                && fact_ventas[horas_lead_time] <= 24
        )
    ),
    [Pedidos]
)
```

### B. Tiempo de entrega en minutos para comparar etapas

Como confirmación y despacho ya están en minutos, conviene normalizar entrega a la misma unidad para comparar qué etapa concentra mayor demora.

```DAX
Minutos Entrega Promedio = [Horas Entrega Promedio] * 60
```

Estas medidas permiten cubrir dos preguntas oficiales del caso:

- qué porcentaje de pedidos se entrega dentro del tiempo objetivo
- qué etapa concentra mayor demora

## 5. Preguntas de negocio

El reporte debe responder como mínimo:

- cuánto vendió la farmacia
- cuánto descuento otorgó
- cuánto margen generó
- cuántos pedidos atendió
- cuántas unidades vendió
- qué productos venden más
- qué familias o categorías concentran ventas y margen
- qué clientes registran mayor volumen de compra y mayor ticket promedio
- qué vendedores generan mayor venta y mejor margen
- cómo se comportan las ventas por fecha
- cuánto tarda el proceso operativo de atención
- qué porcentaje de pedidos se entrega dentro del SLA
- qué etapa del proceso concentra mayor demora
- cómo cambian los indicadores al filtrar por fecha, producto o estado

## 6. Regla didáctica de esta práctica

Los visuales deben construirse con medidas DAX, no con columnas numéricas arrastradas directamente desde `fact_ventas`.

Uso correcto:

```text
dimensiones -> ejes, filas, columnas, filtros
medidas DAX -> valores de KPIs, gráficos y matrices
```

Uso que se debe evitar:

```text
fact_ventas[venta_neta] arrastrada como suma improvisada en cada visual
```

La página debe consumir métricas gobernadas, no redefinir la lógica en cada gráfico.

## 7. Crear la página del reporte

En Power BI:

1. Ve a la vista `Informe`.
2. Crea una nueva página.
3. Renombra la página como `Resumen BI`.
4. Ajusta el lienzo a formato panorámico si no lo está.
5. Activa cuadrícula o guías si deseas alinear mejor los visuales.

Estructura recomendada:

```text
+------------------------------------------------------------+
| Segmentadores: Año | Familia | Categoría | Estado           |
+------------------------------------------------------------+
| Ventas | Descuentos | Margen | % Margen | Pedidos | Unidades |
+------------------------------------------------------------+
| Ticket Promedio | % Pedidos a Tiempo | Lead Time Promedio    |
+------------------------------------------------------------+
| Evolución temporal                  | Matriz producto       |
|                                     |                       |
+------------------------------------------------------------+
| Top clientes          | Top vendedores        | Tiempos      |
+------------------------------------------------------------+
```

## 8. Visuales mínimos

### 8.1 Tarjetas KPI

Crea tarjetas para:

- `[Ventas Netas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`
- `[% Pedidos a Tiempo]`

Formato recomendado:

- ventas, descuentos, margen y ticket: moneda
- porcentaje de margen: porcentaje con 1 o 2 decimales
- pedidos a tiempo: porcentaje con 1 o 2 decimales
- pedidos y unidades: número entero
- títulos cortos y claros

Lectura esperada:

- el usuario debe entender el resultado general sin mirar aún los gráficos
- las tarjetas deben cambiar cuando se apliquen filtros
- ninguna tarjeta debe usar una columna sin medida

### 8.2 Evolución temporal

Crea un gráfico de líneas.

Eje:

- `dim_fecha[fecha]`

Valores:

- `[Ventas Netas]`
- `[Ventas Netas Acumuladas]`

Configuración recomendada:

- orden ascendente por fecha
- título: `Evolución de ventas`
- eje Y en moneda
- leyenda visible si se muestran ambas medidas

Uso esperado:

- observar tendencia diaria o mensual
- comparar venta del período con venta acumulada
- detectar días o períodos de mayor actividad

Si la línea aparece demasiado granular, prueba usar la jerarquía `Calendario` en lugar de la fecha directa.

### 8.3 Matriz por producto

Crea una matriz.

Filas:

- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_producto[nombre_producto]`

Valores:

- `[Ventas Netas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Unidades Vendidas]`

Uso esperado:

- observar resultados por familia
- bajar a categoría
- revisar producto
- comparar ventas, descuentos y margen en el mismo contexto

Configuración recomendada:

- ordenar por `[Ventas Netas]` descendente
- activar subtotales por familia y categoría
- mantener porcentaje de margen como porcentaje
- evitar mostrar demasiados decimales

Nota:

El drill-down formal y el drill-through se trabajan en la siguiente sesión. En esta práctica basta con una matriz navegable por niveles.

### 8.4 Ventas por cliente

Crea un gráfico de barras o columnas.

Eje:

- `dim_cliente[nombre_cliente]`

Valores:

- `[Ventas Netas]`
- `[Unidades Vendidas]`

Tooltip recomendado:

- `[Ticket Promedio]`

Orden:

- descendente por `[Ventas Netas]`

Filtro visual recomendado:

- Top N de clientes por `[Ventas Netas]`
- usar 10 o 15 clientes para evitar saturación

Uso esperado:

- identificar clientes que concentran mayor venta y mayor volumen
- revisar el ticket promedio de esos clientes en tooltip o etiqueta secundaria
- comprobar que el ranking cambia al filtrar por familia, categoría o fecha

### 8.5 Ventas por vendedor

Crea un gráfico de barras o columnas.

Eje:

- `dim_vendedor[nombre_vendedor]`

Valores:

- `[Ventas Netas]`
- `[Margen Bruto]`

Tooltip recomendado:

- `[Pedidos]`
- `[Descuentos]`

Configuración recomendada:

- si usas dos medidas con escalas muy distintas, considera gráfico combinado
- si el gráfico se vuelve confuso, deja `[Ventas Netas]` en barras y muestra `[Pedidos]` en tooltip

Uso esperado:

- comparar desempeño comercial por vendedor
- revisar si el mayor vendedor por monto también genera mejor margen
- revisar descuentos o pedidos sin sobrecargar el eje principal

### 8.6 Tiempos operativos y SLA

Crea tarjetas pequeñas o un gráfico de columnas para:

- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Horas Entrega Promedio]`
- `[Horas Lead Time Promedio]`
- `[% Pedidos a Tiempo]`

Para comparar qué etapa concentra mayor demora, agrega además una visual comparativa usando minutos:

- `[Minutos Confirmación Promedio]`
- `[Minutos Despacho Promedio]`
- `[Minutos Entrega Promedio]`

Regla importante:

Estas métricas son promedios. No deben mostrarse como suma.

Uso esperado:

- analizar eficiencia operativa
- revisar si ciertos filtros elevan tiempos de atención
- conectar desempeño comercial con desempeño logístico
- identificar si la mayor demora está en confirmación, despacho o entrega

## 9. Segmentadores recomendados

Agrega segmentadores para:

- `dim_fecha[anio]`
- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_estado_pedido[estado_pedido]`

Configuración recomendada:

- colocar los segmentadores en la parte superior o lateral
- usar listas desplegables si ocupan mucho espacio
- permitir selección múltiple cuando tenga sentido
- mantener nombres de campos comprensibles para negocio

Estos filtros deben afectar los visuales principales:

- tarjetas KPI
- gráfico temporal
- matriz por producto
- gráfico de clientes
- gráfico de vendedores
- tiempos operativos

## 10. Filtros de visual y filtros de página

Además de segmentadores, puedes usar filtros del panel lateral.

Ejemplos útiles:

- Top 10 clientes por `[Ventas Netas]`
- Top 10 productos por `[Ventas Netas]`
- Top 10 productos por `[Descuentos]`
- excluir estados anulados si el análisis se concentra en ventas efectivas
- filtrar un año específico para revisar consistencia

Recomendación:

Los filtros visibles deben ser los que el usuario final necesita manipular. Los filtros técnicos o de limpieza pueden quedar en el panel de filtros.

## 11. Interacciones entre visuales

Verifica que seleccionar un elemento de un visual afecte al resto de la página.

Prueba mínima:

1. Selecciona una familia en la matriz.
2. Observa si cambian las tarjetas KPI.
3. Observa si cambian los gráficos de cliente y vendedor.
4. Selecciona un cliente en el gráfico de barras.
5. Observa si la matriz y los KPIs responden.

Si un visual no debe filtrar a otro, ajusta la opción:

```text
Formato -> Editar interacciones
```

En esta primera página, la mayoría de visuales puede mantener interacción activa.

## 12. Validación funcional

### 12.1 Validar una tarjeta contra SQL

Consulta:

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

Debe coincidir con la tarjeta `[Ventas Netas]` cuando no hay filtros activos.

### 12.2 Validar margen contra SQL

Consulta:

```sql
SELECT SUM(margen_bruto) AS margen_bruto
FROM marts.fact_ventas;
```

Debe coincidir con la tarjeta `[Margen Bruto]` cuando no hay filtros activos.

### 12.3 Validar descuentos contra SQL

Consulta:

```sql
SELECT SUM(descuento_total) AS descuentos
FROM marts.fact_ventas;
```

Debe coincidir con la tarjeta `[Descuentos]` cuando no hay filtros activos.

### 12.4 Validar porcentaje de margen contra SQL

Consulta:

```sql
SELECT
    SUM(margen_bruto) / NULLIF(SUM(venta_neta), 0) AS pct_margen_bruto
FROM marts.fact_ventas;
```

Debe coincidir con `[% Margen Bruto]`.

No debe validarse como:

```sql
SELECT AVG(pct_margen_bruto)
FROM marts.fact_ventas;
```

Ese promedio simple puede ser incorrecto porque el porcentaje de margen es una métrica no aditiva.

### 12.5 Validar ticket promedio contra SQL

Consulta:

```sql
SELECT
    SUM(venta_neta) / NULLIF(COUNT(DISTINCT pedido_id), 0) AS ticket_promedio
FROM marts.fact_ventas;
```

Debe coincidir con `[Ticket Promedio]`.

### 12.6 Validar porcentaje de pedidos a tiempo contra SQL

Usa `SLA = 24 horas`.

```sql
SELECT
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN horas_lead_time <= 24 THEN pedido_id END)
        / NULLIF(COUNT(DISTINCT pedido_id), 0),
        2
    ) AS pct_pedidos_a_tiempo
FROM marts.fact_ventas;
```

Debe coincidir con `[% Pedidos a Tiempo]`.

### 12.7 Validar ventas por producto contra SQL

Consulta:

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

### 12.8 Validar ventas por familia contra SQL

Consulta:

```sql
SELECT
    dp.nombre_familia,
    SUM(fv.venta_neta) AS ventas_netas,
    SUM(fv.margen_bruto) AS margen_bruto,
    SUM(fv.margen_bruto) / NULLIF(SUM(fv.venta_neta), 0) AS pct_margen_bruto
FROM marts.fact_ventas AS fv
INNER JOIN marts.dim_producto AS dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_familia
ORDER BY ventas_netas DESC;
```

Debe coincidir con el primer nivel de la matriz por producto.

### 12.9 Validar etapa con mayor demora

Consulta:

```sql
SELECT 'confirmacion' AS etapa, AVG(minutos_confirmacion) AS promedio_minutos
FROM marts.fact_ventas
UNION ALL
SELECT 'despacho' AS etapa, AVG(minutos_despacho) AS promedio_minutos
FROM marts.fact_ventas
UNION ALL
SELECT 'entrega' AS etapa, AVG(horas_entrega) * 60 AS promedio_minutos
FROM marts.fact_ventas;
```

La etapa con mayor promedio en minutos debe coincidir con la visual comparativa de tiempos.

### 12.10 Validar que los filtros funcionen

Selecciona una categoría en el segmentador.

Debes observar que cambian:

- tarjetas KPI
- gráfico temporal
- matriz de productos
- gráficos de cliente y vendedor
- tiempos operativos

Si no cambian, revisa:

- relaciones del modelo
- dirección de filtro cruzado
- uso de campos de dimensión correctos
- medidas DAX usadas en los visuales
- interacciones desactivadas por accidente

## 13. Diseño mínimo de página

La página debe priorizar lectura analítica:

- primera fila: tarjetas KPI
- zona central: evolución temporal y matriz por producto
- zona superior o lateral: segmentadores
- zona inferior: cliente, vendedor y tiempos operativos

Evita mezclar demasiados colores. Usa formatos consistentes:

- moneda para ventas y margen
- moneda para descuentos y ticket promedio
- porcentaje para ratios
- enteros para conteos
- decimales moderados para tiempos

Buenas prácticas:

- usa títulos claros
- alinea visuales
- evita visuales excesivamente pequeños
- limita rankings para que sean legibles
- no repitas el mismo indicador en demasiados lugares
- no uses colores decorativos sin significado

## 14. Checklist de revisión

Antes de entregar, verifica:

- la página se llama `Resumen BI`
- las tarjetas muestran medidas DAX
- los montos usan formato moneda
- los porcentajes usan formato porcentaje
- los conteos no muestran decimales
- existe evidencia de descuentos y ticket promedio
- existe evidencia del SLA de 24 horas
- los segmentadores modifican todos los visuales principales
- el gráfico temporal está ordenado correctamente
- la matriz permite leer familia, categoría y producto
- los rankings de cliente o vendedor están ordenados por ventas
- la validación SQL coincide con Power BI sin filtros activos

## 15. Errores comunes

Error 1:

Usar `fact_ventas[venta_neta]` directamente en cada gráfico.

Corrección:

Usar la medida `[Ventas Netas]`.

Error 2:

Mostrar `% Margen Bruto` como promedio de una columna.

Corrección:

Usar la medida:

```DAX
% Margen Bruto = DIVIDE([Margen Bruto], [Ventas Netas])
```

Error 3:

Los segmentadores no afectan a un gráfico.

Corrección:

Revisar relaciones, dirección de filtro e interacciones del visual.

Error 4:

El ranking de clientes muestra demasiadas barras.

Corrección:

Aplicar filtro Top N por `[Ventas Netas]`.

Error 5:

Los tiempos operativos aparecen sumados.

Corrección:

Usar medidas promedio.

Error 6:

La comparación entre etapas usa minutos y horas mezclados.

Corrección:

Usar `[Minutos Entrega Promedio]` para comparar confirmación, despacho y entrega en la misma unidad.

## 16. Evidencias a entregar

Entrega:

- captura de tarjetas KPI
- captura de gráfico temporal
- captura de matriz por producto
- captura de filtros aplicados
- captura de ventas por cliente o vendedor
- captura de tiempos operativos
- captura de descuentos o ticket promedio
- captura de porcentaje de pedidos a tiempo
- captura de validación contra SQL
- archivo `.pbix` guardado en la carpeta `powerbi`

Nombre sugerido del archivo:

```text
FarmaciaPBI_U2_S4_ResumenBI.pbix
```

## 17. Rúbrica breve

| Criterio | Logro esperado |
| --- | --- |
| KPIs | Usa medidas DAX y formatos correctos, incluyendo descuentos, ticket y SLA |
| Visuales | Incluye temporalidad, producto, cliente, vendedor y tiempos |
| Filtros | Segmentadores afectan el análisis completo |
| Validación | KPIs principales coinciden contra SQL |
| Diseño | La página es legible y tiene jerarquía visual |
| Interpretación | El alumno puede explicar qué cambia al aplicar filtros |

## 18. Cierre

Con esta práctica se construye la primera página BI base. El reporte ya no es solo un modelo semántico con medidas: ahora comunica resultados de negocio mediante KPIs, filtros y visuales.

La siguiente sesión profundiza en interactividad avanzada:

- drill-down
- drill-through
- tooltips
- segmentación
- navegación analítica

La idea es pasar de una página base de lectura a un panel interactivo de exploración.
