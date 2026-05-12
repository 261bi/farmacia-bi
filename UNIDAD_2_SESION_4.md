# Unidad 2 - Sesión 4

## Sesión 9 - Visualización BI base

Este documento deja congelada la cuarta sesión macro de la Unidad 2 para el siguiente semestre.

La sesión corresponde al bloque:

```text
Unidad 2 - Construcción del BI
Sesión 9 - Visualización BI base: KPIs, métricas, filtros y primera página de reporte
```

## Alcance

- KPIs comerciales y operativos
- métricas visuales en Power BI
- filtros y segmentadores
- visualización base sobre modelo estrella
- lectura por tiempo, producto, cliente y vendedor
- validación visual contra SQL

## Prácticas que la componen

- [SESION_U2_S4_P1_VISUALIZACION_BI_BASE.md](powerbi/SESION_U2_S4_P1_VISUALIZACION_BI_BASE.md)

## Lógica didáctica

- el estudiante parte del modelo semántico creado en la sesión 3
- usa medidas DAX ya gobernadas
- construye visuales base sin redefinir métricas en cada gráfico
- organiza una primera página BI con jerarquía de lectura
- agrega filtros para modificar el contexto de análisis
- valida que los filtros afecten correctamente a KPIs, gráficos y matrices
- contrasta los resultados principales contra consultas SQL del DataMart

## Nota conceptual

La sesión 3 construye el modelo semántico y las métricas.

La sesión 4 usa ese modelo para crear una primera página BI:

```text
Modelo semántico -> Medidas DAX -> KPIs -> Filtros -> Visuales base
```

Aquí el foco ya no es modelar, sino comunicar indicadores de negocio de forma clara, consistente y verificable.

En BI, una página base no debe ser una colección de gráficos sueltos. Debe responder preguntas de negocio:

- cuánto se vendió
- cuánto margen se generó
- qué productos, clientes o vendedores explican el resultado
- cómo evoluciona la venta en el tiempo
- qué pasa cuando cambia el filtro de fecha, producto o estado

## Resultado esperado

Al finalizar la sesión, el alumno debe tener una primera página de reporte Power BI construida sobre el modelo semántico de la sesión anterior, con:

- tarjetas KPI para ventas, margen, porcentaje de margen, pedidos y unidades
- gráfico temporal para evolución de ventas
- matriz de análisis por familia, categoría y producto
- visuales comparativos por cliente y vendedor
- indicadores operativos de confirmación, despacho, entrega y lead time
- segmentadores funcionales para filtrar el análisis
- validación cruzada entre visuales y consultas SQL del DataMart

## Capacidades que se ejercitan

- traducir medidas DAX en visuales útiles para negocio
- organizar una página BI con jerarquía de lectura clara
- diferenciar KPI, gráfico comparativo, matriz y filtro
- comprobar que los filtros impacten correctamente todas las visualizaciones
- interpretar cambios de contexto por fecha, producto y estado
- detectar inconsistencias entre el reporte y la fuente analítica
- documentar evidencia visual y evidencia SQL

## Artefacto principal

El entregable central de esta sesión es una primera página operativa de dashboard en Power BI, apoyada en el modelo estrella del schema `marts`.

En términos de flujo de valor:

```text
DataMart validado -> Modelo semántico -> Medidas DAX -> Página BI base -> Lectura de KPIs
```

## Distribución sugerida de la clase

| Bloque | Actividad | Tiempo sugerido |
| --- | --- | --- |
| Apertura | Repaso del modelo semántico y medidas DAX | 15 min |
| Construcción | Tarjetas KPI y formato de métricas | 25 min |
| Construcción | Gráfico temporal y matriz por producto | 35 min |
| Construcción | Visuales por cliente, vendedor y tiempos operativos | 30 min |
| Interacción | Segmentadores y filtros de página | 25 min |
| Validación | Comparación Power BI contra SQL | 25 min |
| Cierre | Evidencias, errores comunes y continuidad | 15 min |

## Criterios mínimos de logro

- los KPIs muestran valores coherentes sin filtros activos
- los segmentadores modifican tarjetas, gráficos y matrices
- la matriz permite lectura por producto en más de un nivel analítico
- los gráficos permiten identificar top clientes o vendedores
- los tiempos operativos se muestran como promedios, no como sumas
- al menos una validación visual queda contrastada con SQL
- el reporte mantiene formato consistente para moneda, porcentaje y conteos

## Evidencia esperada

- archivo `.pbix` con la página base construida
- captura de KPIs principales
- captura de gráfico temporal
- captura de matriz por producto
- captura de visual por cliente o vendedor
- captura con filtros aplicados
- evidencia de validación entre Power BI y SQL

## Errores comunes a vigilar

- usar columnas numéricas de `fact_ventas` directamente en lugar de medidas DAX
- promediar porcentajes fila por fila
- mostrar tiempos operativos como suma
- usar demasiados colores sin significado analítico
- crear visuales que no cambian al aplicar filtros
- mezclar campos de tablas no relacionadas
- validar solo "a ojo" sin consulta SQL de respaldo

## Continuidad

La siguiente sesión profundiza la interacción del usuario con el reporte y ya no se limita a una página base estática.

Continúa con:

- diseño de paneles interactivos
- drill-down y drill-through
- tooltips
- segmentación analítica
- navegación guiada del reporte

En otras palabras, esta sesión construye la base visual; la siguiente mejora la exploración guiada del tablero.
