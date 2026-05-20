# Sesión U2 S5 P2: KPI de variación con iconos y colores en Power BI

## 1. Título

Construcción de una tabla KPI con variación de ventas, comparación contra año previo, iconos semáforo y formato condicional.

## 2. Objetivo

Crear un visual de seguimiento por categoría que permita comparar ventas actuales contra ventas del mismo periodo del año previo, identificar variaciones positivas o negativas y comunicar el resultado con iconos y colores.

Al finalizar la práctica, el alumno debe poder:

- crear medidas DAX de comparación temporal basadas en `dim_fecha`
- calcular variación absoluta y porcentual de ventas
- construir una tabla o matriz KPI por categoría
- aplicar formato condicional con iconos
- usar colores con intención de negocio
- validar el resultado contra SQL
- interpretar qué categorías mejoran o caen frente al periodo previo

## 3. Relación con prácticas previas

Esta práctica continúa desde:

- [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)
- [SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md](SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md)

La P1 construyó el dashboard ejecutivo. Esta P2 agrega una lectura puntual de desempeño: no solo cuánto se vendió, sino si la venta subió o bajó contra el mismo periodo del año anterior.

## 4. Idea central

Un KPI ejecutivo debe responder rápido:

```text
valor actual -> valor comparable -> variación -> señal visual
```

La señal visual no reemplaza el dato. Lo resume para que el usuario detecte prioridades.

Ejemplo de lectura:

```text
La categoría ACCESORIOS vendió más que el mismo periodo del año anterior y aparece con indicador verde.
La categoría FOOD cayó frente al año previo y aparece con indicador rojo.
```

## 5. Página de trabajo

Puedes trabajar sobre la página:

```text
Resumen BI
```

O crear una página específica:

```text
KPI Variación Ventas
```

Si el dashboard de la P1 ya está cargado, agrega este visual como bloque de análisis comercial.

## 6. Medidas DAX

Agrega estas medidas en la tabla `_Medidas`.

En esta práctica no usaremos funciones de inteligencia de tiempo como `SAMEPERIODLASTYEAR` o `DATEADD`. La comparación se construirá con la dimensión `dim_fecha`, usando sus atributos de negocio:

- `dim_fecha[anio]`
- `dim_fecha[trimestre]`
- `dim_fecha[mes_numero]`
- `dim_fecha[mes_desc]`

Para que la medida sea fácil de interpretar, trabaja con un solo año seleccionado en el segmentador.

### 6.1 Ventas año previo mismo periodo

```DAX
Ventas Año Previo Mismo Periodo =
VAR AnioActual = SELECTEDVALUE(dim_fecha[anio])
VAR MesesSeleccionados = VALUES(dim_fecha[mes_numero])
RETURN
IF(
    ISBLANK(AnioActual),
    BLANK(),
    CALCULATE(
        [Ventas Netas],
        REMOVEFILTERS(dim_fecha),
        dim_fecha[anio] = AnioActual - 1,
        TREATAS(MesesSeleccionados, dim_fecha[mes_numero])
    )
)
```

Esta medida compara el año seleccionado contra el año anterior, respetando el mes o grupo de meses filtrado desde `dim_fecha`.

Ejemplos:

- si filtras marzo de 2025, compara contra marzo de 2024
- si filtras el primer trimestre de 2025, compara contra el primer trimestre de 2024
- si filtras una categoría, mantiene la categoría y cambia solo el periodo

Si no seleccionas un año único, la medida queda en blanco para evitar una comparación ambigua.

### 6.2 Variación ventas

```DAX
Variación Ventas =
[Ventas Netas] - [Ventas Año Previo Mismo Periodo]
```

### 6.3 % Variación ventas

```DAX
% Variación Ventas =
DIVIDE(
    [Variación Ventas],
    [Ventas Año Previo Mismo Periodo]
)
```

### 6.4 KPI variación ventas

```DAX
KPI Variación Ventas =
SWITCH(
    TRUE(),
    [% Variación Ventas] > 0, 1,
    [% Variación Ventas] < 0, -1,
    0
)
```

Esta medida sirve para aplicar reglas de iconos.

## 7. Visual KPI por categoría

Crea una tabla o matriz.

Filas:

- `dim_producto[nombre_categoria]`

Valores:

- `[Ventas Netas]`
- `[Ventas Año Previo Mismo Periodo]`
- `[% Variación Ventas]`
- `[KPI Variación Ventas]`

Formato sugerido:

- `[Ventas Netas]`: moneda
- `[Ventas Año Previo Mismo Periodo]`: moneda
- `[% Variación Ventas]`: porcentaje con 2 decimales
- `[KPI Variación Ventas]`: mostrar como icono, no como número

Ordena la tabla por `[Ventas Netas]` o por `[% Variación Ventas]`, según la pregunta de análisis.

## 8. Formato condicional con iconos

En el campo `[KPI Variación Ventas]`, aplica formato condicional de iconos.

Ruta sugerida en Power BI:

```text
Visual -> Valores -> KPI Variación Ventas -> Formato condicional -> Iconos
```

Configura reglas:

```text
Si valor es mayor que 0  -> triángulo/flecha arriba -> verde
Si valor es igual a 0    -> círculo o línea          -> gris
Si valor es menor que 0  -> triángulo/flecha abajo   -> rojo
```

Recomendación:

- activa `Solo icono` si Power BI lo permite
- usa verde solo para mejora
- usa rojo solo para deterioro
- evita colores decorativos sin significado

## 9. Formato condicional en porcentaje

Aplica color de fuente o color de fondo sobre `[% Variación Ventas]`.

Reglas sugeridas:

```text
Mayor que 0 -> verde
Menor que 0 -> rojo
Igual a 0   -> gris
```

El objetivo es que el usuario pueda leer tanto el número exacto como la señal visual.

## 10. Segmentadores recomendados

Agrega o reutiliza segmentadores:

- `dim_fecha[anio]`
- `dim_fecha[trimestre]`
- `dim_fecha[mes_desc]`
- `dim_producto[nombre_familia]`
- `dim_estado_pedido[estado_pedido]`

Prueba:

1. Filtra un solo año con datos comparables contra el año anterior.
2. Filtra una familia de productos.
3. Observa qué categorías cambian de color.
4. Identifica una categoría que creció y una que cayó.

## 11. Preguntas de análisis

Responde con base en el visual:

- ¿qué categoría tiene mayor venta actual?
- ¿qué categoría creció más frente al año previo?
- ¿qué categoría cayó más?
- ¿la categoría con mayor venta también es la que más crece?
- ¿hay categorías con buena venta pero variación negativa?
- ¿qué acción comercial sugerirías para una categoría en rojo?

## 12. Validación SQL

La validación depende del año seleccionado en Power BI. Ajusta los años según tus datos.

Ejemplo para comparar 2025 contra 2024:

```sql
SELECT
    dp.nombre_categoria,
    SUM(CASE WHEN df.anio = 2025 THEN fv.venta_neta ELSE 0 END) AS ventas_actuales,
    SUM(CASE WHEN df.anio = 2024 THEN fv.venta_neta ELSE 0 END) AS ventas_anio_previo,
    SUM(CASE WHEN df.anio = 2025 THEN fv.venta_neta ELSE 0 END)
        - SUM(CASE WHEN df.anio = 2024 THEN fv.venta_neta ELSE 0 END) AS variacion_ventas,
    (
        SUM(CASE WHEN df.anio = 2025 THEN fv.venta_neta ELSE 0 END)
        - SUM(CASE WHEN df.anio = 2024 THEN fv.venta_neta ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN df.anio = 2024 THEN fv.venta_neta ELSE 0 END), 0) AS pct_variacion_ventas
FROM marts.fact_ventas fv
JOIN marts.dim_fecha df
    ON fv.fecha_key = df.fecha_key
JOIN marts.dim_producto dp
    ON fv.producto_key = dp.producto_key
GROUP BY dp.nombre_categoria
ORDER BY ventas_actuales DESC;
```

Si el filtro en Power BI usa meses o trimestres, replica ese mismo filtro en SQL.

## 13. Interpretación ejecutiva

Redacta tres conclusiones breves.

Plantilla:

```text
Categoría:
Ventas actuales:
Ventas año previo:
% variación:
Señal visual:
Interpretación:
Acción sugerida:
```

Ejemplo:

```text
La categoría X presenta una variación negativa frente al mismo periodo del año previo. Aunque mantiene ventas relevantes, el indicador rojo sugiere revisar precio, descuentos, disponibilidad o cambios en la demanda.
```

## 14. Checklist

- existe visual KPI por categoría
- se muestran ventas actuales y ventas del año previo
- la variación porcentual está formateada como porcentaje
- el KPI usa iconos de subida, bajada o estabilidad
- los colores tienen significado consistente
- los segmentadores modifican correctamente el visual
- al menos una categoría positiva y una negativa fueron interpretadas
- el resultado fue validado contra SQL

## 15. Evidencias a entregar

- captura de la tabla KPI con iconos y colores
- captura del panel de reglas de iconos
- captura con filtro de año aplicado
- captura de validación SQL
- tres conclusiones ejecutivas

Nombre sugerido:

```text
FarmaciaPBI_U2_S5_P2_KPI_Variacion_Ventas.pbix
```

## 16. Cierre

Con esta práctica, el dashboard deja de mostrar solo valores acumulados y empieza a comunicar desempeño comparativo. Los iconos y colores ayudan a detectar rápidamente dónde la venta mejora, cae o se mantiene estable.
