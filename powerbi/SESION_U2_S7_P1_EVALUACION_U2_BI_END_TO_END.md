# Sesión U2 S7 P1: Evaluación U2 BI end-to-end

## 1. Título

Evaluación integral de la Unidad 2: construcción del BI desde OLTP hasta Power BI.

## 2. Objetivo

Evaluar que el estudiante pueda construir, explicar, validar e interpretar un flujo BI completo para el caso farmacia.

La evaluación integra:

- OLTP MySQL
- ingesta hacia PostgreSQL
- transformación con dbt
- DataMart en schema `marts`
- modelo semántico en Power BI
- medidas DAX
- exploración OLAP y storytelling
- dashboard con KPIs
- gobierno del dato
- validación analítica contra SQL

## 3. Producto final

El alumno entrega un paquete BI compuesto por:

- archivo `.pbix` final
- evidencias SQL
- capturas del reporte
- ficha de gobierno del dato
- breve sustentación técnica y funcional

Flujo esperado:

```text
MySQL farmadb
  -> Airbyte
  -> PostgreSQL farmacia_dw.raw
  -> dbt staging
  -> dbt marts
  -> Power BI
```

## 4. Requisitos mínimos

### 4.1 DataMart

Debe existir el schema `marts` con:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

Validación:

```sql
SELECT COUNT(*) FROM marts.fact_ventas;
```

### 4.2 Modelo semántico

Power BI debe consumir tablas de `marts`, no tablas `raw` ni `staging`.

Relaciones esperadas:

```text
dim_fecha -> fact_ventas
dim_cliente -> fact_ventas
dim_vendedor -> fact_ventas
dim_producto -> fact_ventas
dim_estado_pedido -> fact_ventas
```

### 4.3 Medidas

Debe incluir como mínimo:

- `[Ventas Netas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`
- `[Ventas Netas Acumuladas]`
- `[% Pedidos a Tiempo]`

### 4.4 Reporte

Debe incluir:

- página `Exploración OLAP`
- página `Resumen BI`
- KPIs principales
- gráfico temporal
- matriz por producto
- ranking por cliente o vendedor
- filtros funcionales
- una página de detalle o drill-through
- evidencia de tooltip o navegación
- tres hallazgos redactados
- ficha de gobierno del dato

## 5. Actividad de evaluación

El estudiante debe presentar el tablero y responder:

1. ¿Cuál es el origen transaccional del dato?
2. ¿Qué rol cumple Airbyte?
3. ¿Qué diferencia hay entre `raw`, `staging` y `marts`?
4. ¿Cuál es el grano de `fact_ventas`?
5. ¿Por qué Power BI debe usar medidas DAX?
6. ¿Por qué `[% Margen Bruto]` no debe calcularse como promedio simple?
7. ¿Qué dimensión permite analizar por fecha?
8. ¿Qué jerarquía permite analizar producto?
9. ¿Cómo se valida una tarjeta KPI contra SQL?
10. ¿Qué sucede con el contexto de filtro al hacer drill-through?
11. ¿Qué hallazgo de negocio se obtiene del análisis OLAP?
12. ¿Qué debe documentar la ficha de gobierno del dato?
13. ¿Quién es responsable funcional de una métrica como ventas netas?

## 6. Validaciones obligatorias

### 6.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

### 6.2 Margen y porcentaje

```sql
SELECT
    SUM(margen_bruto) AS margen_bruto,
    SUM(margen_bruto) / NULLIF(SUM(venta_neta), 0) AS pct_margen_bruto
FROM marts.fact_ventas;
```

### 6.3 Pedidos y ticket

```sql
SELECT
    COUNT(DISTINCT pedido_id) AS pedidos,
    SUM(venta_neta) / NULLIF(COUNT(DISTINCT pedido_id), 0) AS ticket_promedio
FROM marts.fact_ventas;
```

### 6.4 Producto o familia

```sql
SELECT
    dp.nombre_familia,
    SUM(fv.venta_neta) AS ventas_netas,
    SUM(fv.margen_bruto) AS margen_bruto
FROM marts.fact_ventas fv
JOIN marts.dim_producto dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_familia
ORDER BY ventas_netas DESC;
```

### 6.5 SLA

```sql
SELECT
    COUNT(DISTINCT CASE WHEN horas_lead_time <= 24 THEN pedido_id END)::numeric
        / NULLIF(COUNT(DISTINCT pedido_id), 0) AS pct_pedidos_a_tiempo
FROM marts.fact_ventas;
```

## 7. Rúbrica

| Criterio | Peso | Logro esperado |
| --- | ---: | --- |
| Pipeline BI | 20% | Explica OLTP, ingesta, transformación y DataMart |
| Modelo semántico | 15% | Relaciones correctas, claves ocultas y jerarquías funcionales |
| Medidas DAX | 20% | Métricas correctas, formateadas y reutilizables |
| Exploración y storytelling | 10% | Usa jerarquías, drill-through y hallazgos sustentados |
| Visualización | 15% | Reporte legible con KPIs, filtros y análisis por dimensiones |
| Gobierno del dato | 5% | Incluye linaje, glosario, diccionario de métricas y reglas de calidad |
| Validación | 10% | Contrasta métricas contra SQL y explica diferencias si existen |
| Sustentación | 5% | Interpreta resultados y comunica hallazgos con claridad |

## 8. Evidencias a entregar

- `.pbix` final
- captura del modelo
- captura de medidas
- captura de `Exploración OLAP`
- captura de `Resumen BI`
- captura de página de detalle
- captura de filtros aplicados
- tres hallazgos de negocio
- capturas o resultados SQL de validación
- ficha de gobierno del dato

Nombre sugerido:

```text
FarmaciaPBI_U2_Evaluacion_Final.pbix
```

## 9. Criterios de no logro

Se considera insuficiente si:

- Power BI usa tablas `raw` como fuente principal del reporte
- no existe `fact_ventas` como tabla de hechos
- las relaciones no filtran correctamente
- los KPIs se construyen con columnas improvisadas y no con medidas
- `% Margen Bruto` se calcula como promedio simple
- no hay validación SQL
- no puede explicar linaje, definición o responsable de una métrica crítica
- el alumno no puede explicar el flujo de datos

## 10. Cierre

La evaluación verifica la competencia completa de la Unidad 2: construir un BI funcional, encontrar hallazgos, comunicar una historia de negocio y explicar cómo se gobierna el dato desde el origen hasta la decisión.
