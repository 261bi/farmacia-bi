# Sesión U2 S3 P2: Medidas DAX y agregaciones BI

## 1. Título

Definición de medidas DAX, agregaciones y KPIs comerciales sobre `fact_ventas`.

## 2. Objetivo

Crear una capa de métricas BI en Power BI usando medidas DAX controladas, reutilizables y consistentes con el DataMart.

Al finalizar la práctica, el alumno debe poder:

- diferenciar columnas numéricas de medidas
- crear medidas DAX base
- crear medidas derivadas
- calcular porcentajes y promedios
- validar medidas contra SQL
- usar medidas en visuales y matrices OLAP

## 3. Relación con la práctica previa

Esta práctica continúa desde:

- [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)

Antes de iniciar, verifica:

- las seis tablas de `marts` están importadas
- las relaciones están creadas
- las jerarquías principales existen

## 4. Regla didactica central

En Power BI, el usuario final no debería arrastrar columnas numéricas del hecho para improvisar KPIs.

La práctica correcta es:

- columnas del hecho: materia prima
- medidas DAX: métricas oficiales
- dimensiones: filtros y ejes de análisis

## 5. Tabla recomendada para medidas

Para organizar el modelo, crea una tabla vacía llamada:

```text
_Medidas
```

Forma simple:

1. En Power BI, selecciona `Inicio`.
2. Elige `Especificar datos`.
3. Crea una tabla con una columna dummy.
4. Nombra la tabla como `_Medidas`.
5. Luego oculta la columna dummy.

Las medidas se pueden guardar en esta tabla para que el panel de campos quede ordenado.

## 6. Medidas base

```DAX
Ventas Brutas = SUM(fact_ventas[venta_bruta])
```

```DAX
Descuentos = SUM(fact_ventas[descuento_total])
```

```DAX
Ventas Netas = SUM(fact_ventas[venta_neta])
```

```DAX
Costo Total = SUM(fact_ventas[costo_total])
```

```DAX
Margen Bruto = SUM(fact_ventas[margen_bruto])
```

```DAX
Unidades Vendidas = SUM(fact_ventas[cantidad_vendida])
```

```DAX
Líneas de Venta = COUNTROWS(fact_ventas)
```

## 7. Medidas derivadas

```DAX
Pedidos = DISTINCTCOUNT(fact_ventas[pedido_id])
```

```DAX
% Margen Bruto = DIVIDE([Margen Bruto], [Ventas Netas])
```

```DAX
% Descuento = DIVIDE([Descuentos], [Ventas Brutas])
```

```DAX
Ticket Promedio = DIVIDE([Ventas Netas], [Pedidos])
```

```DAX
Precio Promedio Neto = DIVIDE([Ventas Netas], [Unidades Vendidas])
```

## 8. Medidas operativas

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

## 9. Medidas con contexto de tiempo

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

```DAX
Participación Ventas Netas =
DIVIDE(
    [Ventas Netas],
    CALCULATE([Ventas Netas], ALLSELECTED())
)
```

## 10. Agregaciones correctas por tipo de métrica

Métricas aditivas:

- ventas brutas
- descuentos
- ventas netas
- costo total
- margen bruto
- unidades vendidas

Métricas semi-aditivas o de conteo:

- pedidos
- líneas de venta

Métricas no aditivas:

- porcentaje de margen
- porcentaje de descuento
- ticket promedio
- precio promedio
- tiempos promedio

Regla clave:

- primero suma numeradores y denominadores
- luego calcula el ratio

Por eso, `% Margen Bruto` debe calcularse como:

```DAX
DIVIDE([Margen Bruto], [Ventas Netas])
```

No como promedio simple de `fact_ventas[pct_margen_bruto]`.

## 11. Validación contra SQL

### 11.1 Ventas netas

```sql
SELECT SUM(venta_neta) AS ventas_netas
FROM marts.fact_ventas;
```

Debe coincidir con:

```text
[Ventas Netas]
```

### 11.2 Margen bruto

```sql
SELECT SUM(margen_bruto) AS margen_bruto
FROM marts.fact_ventas;
```

Debe coincidir con:

```text
[Margen Bruto]
```

### 11.3 Porcentaje de margen

```sql
SELECT
    SUM(margen_bruto) / NULLIF(SUM(venta_neta), 0) AS pct_margen_bruto
FROM marts.fact_ventas;
```

Debe coincidir con:

```text
[% Margen Bruto]
```

## 12. Formato de medidas

Configura formato:

- moneda: `[Ventas Brutas]`, `[Descuentos]`, `[Ventas Netas]`, `[Costo Total]`, `[Margen Bruto]`, `[Ticket Promedio]`, `[Precio Promedio Neto]`
- porcentaje: `[% Margen Bruto]`, `[% Descuento]`, `[Participación Ventas Netas]`
- entero: `[Unidades Vendidas]`, `[Pedidos]`, `[Líneas de Venta]`
- decimal: medidas de tiempo promedio

## 13. Archivo de apoyo

Las medidas de esta práctica también quedan listadas en:

- [medidas_farmacia_bi.dax](medidas_farmacia_bi.dax)

## 14. Evidencias a entregar

- captura de la tabla `_Medidas`
- captura de las medidas base creadas
- captura de las medidas derivadas creadas
- captura de una tarjeta con `[Ventas Netas]`
- captura de una tarjeta con `[% Margen Bruto]`
- captura de validación SQL contra Power BI

## 15. Cierre

Con esta práctica, el modelo deja de depender de agregaciones manuales en cada visual. Las métricas principales quedan definidas como una capa semántica reutilizable, consistente y validable.
