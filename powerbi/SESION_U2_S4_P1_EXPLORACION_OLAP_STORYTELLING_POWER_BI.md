# Sesión U2 S4 P1: Exploración OLAP, progresión y storytelling BI

## 1. Título

Exploración de ventas netas por tiempo y producto para identificar hallazgos y construir una narrativa BI.

## 2. Objetivo

Usar jerarquías, filtros e interacciones de Power BI para explorar ventas netas, analizar su progresión temporal y redactar hallazgos de negocio.

Al finalizar la práctica, el alumno debe poder:

- navegar la jerarquía `Calendario`
- navegar la jerarquía `Producto Comercial`
- analizar ventas netas por año, mes, día, familia, categoría y producto
- ordenar correctamente días de semana
- usar drill-down, drill-up y drill-through
- usar tooltips para ampliar contexto
- identificar picos, caídas y concentraciones de venta
- validar un hallazgo contra SQL
- redactar una mini narrativa BI

## 3. Relación con prácticas previas

Esta práctica continúa desde:

- [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)
- [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)

Antes de iniciar, verifica:

- relaciones activas entre dimensiones y `fact_ventas`
- jerarquía `Calendario`
- jerarquía `Producto Comercial`
- medida `[Ventas Netas]`
- medida `[Pedidos]`
- medida `[Unidades Vendidas]`
- medida `[Ticket Promedio]`

Medidas opcionales:

- `[Margen Bruto]`
- `[% Margen Bruto]`

## 4. Idea central

La secuencia de la sesión es:

```text
ventas netas -> exploración -> progresión -> hallazgo -> historia
```

La S4 no busca construir el dashboard final. Busca entender qué está pasando.

## 5. Página de trabajo

Crea una página llamada:

```text
Exploración OLAP
```

Debe contener:

- matriz OLAP por producto
- gráfico de progresión temporal
- tabla de ventas por día de semana
- visual de ventas por categoría
- segmentadores de exploración
- tooltip contextual
- espacio de texto para hallazgos

## 6. Matriz OLAP por producto

Crea una matriz.

Filas:

- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_producto[nombre_producto]`

Valores:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`

Opcional:

- `[Margen Bruto]`
- `[% Margen Bruto]`

Acciones:

1. Expande de familia a categoría.
2. Expande de categoría a producto.
3. Ordena por `[Ventas Netas]`.
4. Identifica la familia con mayor venta.
5. Identifica una categoría que concentre ventas.

Preguntas:

- ¿qué familia vende más?
- ¿qué categoría explica la venta?
- ¿hay productos que concentran el resultado?
- ¿la mayor venta viene de muchos pedidos o de pocos pedidos grandes?

## 7. Progresión temporal

Crea un gráfico de líneas.

Eje:

- jerarquía `Calendario`

Valores:

- `[Ventas Netas]`

Prueba:

1. Lee ventas por año.
2. Baja a trimestre.
3. Baja a mes.
4. Baja a fecha.
5. Identifica picos, caídas o estacionalidad.

Pregunta:

```text
¿La venta cambia por tendencia sostenida o por eventos puntuales?
```

## 8. Ventas por mes y año

Crea un gráfico de líneas o columnas agrupadas.

Eje:

- `dim_fecha[mes_desc]`

Leyenda:

- `dim_fecha[anio]`

Valores:

- `[Ventas Netas]`

Recuerda que `mes_desc` debe estar ordenado por `mes_numero`.

Preguntas:

- ¿qué meses muestran mayor venta?
- ¿qué año tiene mejor comportamiento?
- ¿hay meses comparables con diferencias visibles?

## 9. Ventas por día y año

Crea un gráfico de líneas.

Eje:

- `dim_fecha[dia]`

Leyenda:

- `dim_fecha[anio]`

Valores:

- `[Ventas Netas]`

Uso:

- observar comportamiento diario
- detectar picos dentro del mes
- reforzar la idea de progresión temporal

## 10. Orden temporal del día de semana

Crea una tabla simple.

Filas:

- `dim_fecha[dia_semana_desc]`

Valores:

- `[Ventas Netas]`

Pregunta:

```text
¿Qué sucede con el informe?
```

Si los días aparecen en orden alfabético, corrige:

1. Ve a la vista `Datos`.
2. Selecciona `dim_fecha[dia_semana_desc]`.
3. Elige `Ordenar por columna`.
4. Selecciona `dim_fecha[dia_semana_numero]`.
5. Regresa al informe.

Resultado esperado:

```text
lunes
martes
miércoles
jueves
viernes
sábado
domingo
```

Pregunta final:

```text
¿Cambió el dato o cambió la forma correcta de leerlo?
```

La respuesta esperada: cambió la presentación, no el dato.

## 11. Drill-through de producto

Crea una página:

```text
Detalle Producto
```

Campo de drill-through:

- `dim_producto[nombre_producto]`

Agrega:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- ventas por fecha
- tabla por cliente
- botón `Volver`

Pregunta:

```text
¿El producto depende de pocos clientes o tiene venta distribuida?
```

## 12. Drill-through de cliente

Crea una página:

```text
Detalle Cliente
```

Campo de drill-through:

- `dim_cliente[nombre_cliente]`

Agrega:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Ticket Promedio]`
- matriz por producto
- ventas por fecha
- botón `Volver`

Pregunta:

```text
¿El cliente compra de forma recurrente, concentrada o esporádica?
```

## 13. Tooltip contextual

Crea una página tooltip:

```text
TT Ventas
```

Incluye:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Unidades Vendidas]`
- `[Ticket Promedio]`

Asigna el tooltip a:

- matriz OLAP
- gráfico temporal
- visual por categoría

## 14. Segmentadores de exploración

Agrega segmentadores:

- `dim_fecha[anio]`
- `dim_fecha[mes_desc]`
- `dim_producto[nombre_familia]`
- `dim_estado_pedido[estado_pedido]`

Regla:

- usa campos de negocio
- no uses claves técnicas

## 15. De hallazgo a historia

Un hallazgo debe tener evidencia.

Ejemplo débil:

```text
La categoría X vende más.
```

Ejemplo BI:

```text
La categoría X concentra la mayor venta neta del periodo seleccionado. Al revisar la progresión mensual, la venta se concentra en los meses de mayor actividad, por lo que conviene monitorear disponibilidad y reposición en esos periodos.
```

Estructura:

```text
Contexto -> Evidencia -> Interpretación -> Acción sugerida
```

## 16. Plantilla de narrativa

Completa tres narrativas:

```text
Hallazgo:
Contexto:
Evidencia:
Interpretación:
Acción sugerida:
Visual usado:
Validación SQL:
```

Temas sugeridos:

- familia o categoría
- progresión mensual
- día de semana
- producto
- cliente

## 17. Validación SQL

### 17.1 Ventas por familia

```sql
SELECT
    dp.nombre_familia,
    SUM(fv.venta_neta) AS ventas_netas
FROM marts.fact_ventas fv
JOIN marts.dim_producto dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_familia
ORDER BY ventas_netas DESC;
```

### 17.2 Ventas por mes y año

```sql
SELECT
    df.anio,
    df.mes_numero,
    df.mes_desc,
    SUM(fv.venta_neta) AS ventas_netas
FROM marts.fact_ventas fv
JOIN marts.dim_fecha df
    ON fv.fecha_key = df.fecha_key
GROUP BY
    df.anio,
    df.mes_numero,
    df.mes_desc
ORDER BY
    df.anio,
    df.mes_numero;
```

### 17.3 Ventas por día de semana

```sql
SELECT
    df.dia_semana_numero,
    df.dia_semana_desc,
    SUM(fv.venta_neta) AS ventas_netas
FROM marts.fact_ventas fv
JOIN marts.dim_fecha df
    ON fv.fecha_key = df.fecha_key
GROUP BY
    df.dia_semana_numero,
    df.dia_semana_desc
ORDER BY df.dia_semana_numero;
```

## 18. Checklist

- existe página `Exploración OLAP`
- se usa `[Ventas Netas]` como medida principal
- la matriz permite navegar familia, categoría y producto
- existe visual de progresión temporal
- existe visual de ventas por mes y año
- existe visual de ventas por día y año
- la tabla por día de semana está ordenada correctamente
- existe drill-through de producto
- existe drill-through de cliente
- existe tooltip contextual
- se redactaron tres hallazgos
- al menos un hallazgo fue validado contra SQL

## 19. Evidencias a entregar

- captura de matriz OLAP
- captura de progresión temporal
- captura de ventas por mes y año
- captura de ventas por día y año
- captura de día de semana antes y después de ordenar
- captura de drill-through de producto
- captura de drill-through de cliente
- tres hallazgos redactados
- validación SQL

Nombre sugerido:

```text
FarmaciaPBI_U2_S4_OLAP_Progresion_Storytelling.pbix
```

## 20. Cierre

Con esta práctica, el alumno aprende a explorar ventas netas, leer su progresión y convertir observaciones en hallazgos. La siguiente sesión convierte esos hallazgos en una página ejecutiva con KPIs.
