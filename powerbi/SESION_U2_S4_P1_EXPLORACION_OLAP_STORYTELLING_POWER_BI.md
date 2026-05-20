# Sesión U2 S4 P1: Exploración OLAP, progresión y storytelling BI

## 1. Título

Exploración de ventas netas por tiempo y producto para identificar hallazgos y construir una narrativa BI.

## 2. Objetivo

Usar jerarquías, filtros e interacciones de Power BI para explorar ventas netas, analizar su progresión temporal y redactar hallazgos de negocio.

Al finalizar la práctica, el alumno debe poder:

- navegar la jerarquía `Calendario`
- navegar la jerarquía `Producto Comercial`
- analizar ventas netas por año, mes, día, familia, categoría y producto
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
- gráfico de progresión mensual y acumulada
- gráfico comparativo por mes y año
- tabla de ventas por día de semana
- análisis diario opcional para investigar picos
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

Interpretación importante:

```text
La columna [Pedidos] no se suma verticalmente como [Ventas Netas] o [Unidades Vendidas].
```

Un mismo pedido puede contener productos de más de una familia o categoría. Por eso:

- el subtotal de una familia cuenta los pedidos distintos que incluyen productos de esa familia
- el subtotal de otra familia puede contar algunos de esos mismos pedidos
- el total general cuenta pedidos distintos una sola vez

Entonces, si los pedidos por familia suman más que el total general, no es un error. Significa que algunos pedidos compraron productos de varias familias.

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

## 7. Progresión mensual y acumulada

Crea un gráfico de líneas.

Eje:

- `dim_fecha[mes_desc]`

Valores:

- `[Ventas Netas]`
- `[Ventas Netas Acumuladas]`

Segmentador:

- `dim_fecha[anio]`

Selecciona un solo año para iniciar la lectura.

Recuerda que `mes_desc` debe estar ordenado por `mes_numero`.

Prueba:

1. Selecciona `2024`.
2. Observa la venta mensual y la línea acumulada.
3. Selecciona `2025`.
4. Compara si el acumulado crece de forma parecida o diferente.
5. Selecciona `2026`.
6. Observa que el acumulado se detiene en mayo porque el año está incompleto.

Pregunta:

```text
¿El avance acumulado del año actual puede compararse contra un año completo?
```

Respuesta esperada:

```text
No directamente. 2026 solo tiene datos hasta mayo; debe compararse contra el mismo periodo de años anteriores o indicarse que es un año parcial.
```

## 8. Ventas por mes y año

Crea un gráfico de líneas.

Eje:

- `dim_fecha[mes_desc]`

Leyenda:

- `dim_fecha[anio]`

Valores:

- `[Ventas Netas]`

Recuerda que `mes_desc` debe estar ordenado por `mes_numero`.

Uso:

- comparar meses equivalentes entre años
- detectar meses fuertes o débiles
- mostrar visualmente que 2026 es un periodo parcial

Preguntas:

- ¿qué meses muestran mayor venta?
- ¿qué año tiene mejor comportamiento?
- ¿hay meses comparables con diferencias visibles?
- ¿2026 debe leerse como año completo o como periodo parcial?

Interpretación esperada:

```text
2026 no debe compararse contra todo 2024 o todo 2025 como año completo. Solo tiene datos hasta mayo, por eso su línea termina antes.
```

## 9. Ventas por día de semana

Crea una tabla o gráfico de barras.

Filas o eje:

- `dim_fecha[dia_semana_desc]`

Valores:

- `[Ventas Netas]`
- `[Pedidos]`
- `[Ticket Promedio]`

Pregunta principal:

```text
¿Qué día de semana concentra mayor venta neta?
```

Preguntas de lectura:

- ¿el día con más ventas también tiene más pedidos?
- ¿hay días con menos pedidos pero mayor ticket promedio?
- ¿conviene reforzar stock o atención en ciertos días?

Nota:

- el orden de `dim_fecha[dia_semana_desc]` ya debe estar configurado en el modelo semántico
- si el orden aparece alfabético, vuelve a la S3 P1 y revisa la sección `8. Orden semántico de fechas`

## 10. Detalle diario para investigar picos

Esta actividad es opcional. Úsala solo si en los gráficos mensuales aparece un pico o caída que necesita explicación.

Crea un gráfico de columnas.

Eje:

- `dim_fecha[dia]`

Valores:

- `[Ventas Netas]`

Segmentadores obligatorios:

- `dim_fecha[anio]`
- `dim_fecha[mes_desc]`

Uso:

- selecciona primero un año
- selecciona luego un mes
- sirve para detectar picos puntuales dentro de un periodo filtrado

Pregunta:

```text
¿El pico observado corresponde a un comportamiento recurrente o a un día puntual?
```

Nota:

```text
La lectura por fecha exacta puede generar ruido si se muestran muchos años o meses a la vez. Primero analiza mes y acumulado; luego baja al día solo si necesitas explicar un pico.
```

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
- gráfico de progresión mensual
- gráfico comparativo por mes y año
- visual de ventas por día de semana

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
- existe visual de progresión mensual y acumulada
- existe visual de ventas por mes y año
- si se usa análisis diario, está filtrado por año y mes
- la tabla por día de semana respeta el orden configurado en el modelo semántico
- existe drill-through de producto
- existe drill-through de cliente
- existe tooltip contextual
- se redactaron tres hallazgos
- al menos un hallazgo fue validado contra SQL

## 19. Evidencias a entregar

- captura de matriz OLAP
- captura de progresión mensual y acumulada
- captura de ventas por mes y año
- captura opcional de ventas por día del mes
- captura de ventas por día de semana
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
