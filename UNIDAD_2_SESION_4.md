# Unidad 2 - Sesión 4

## Sesión 9 - Exploración OLAP, hallazgos y storytelling BI

Este documento deja congelada la cuarta sesión macro de la Unidad 2.

La sesión corresponde al bloque:

```text
Unidad 2 - Construcción del BI
Sesión 9 - OLAP -> análisis -> hallazgos -> storytelling
```

## Por qué esta sesión va aquí

La sesión 3 ya dejó construido el modelo semántico:

- relaciones entre dimensiones y hecho
- jerarquía `Calendario`
- jerarquía `Producto Comercial`
- medidas DAX oficiales
- agregaciones consistentes

El siguiente paso no debe ser diseñar un dashboard final de inmediato. Primero el estudiante debe aprender a leer el modelo:

```text
OLAP -> exploración -> comparación -> hallazgo -> historia de negocio
```

Drill-down, drill-through y tooltips no son solo funcionalidades de Power BI. Son mecanismos para encontrar una explicación: qué cambió, dónde cambió, por qué podría haber cambiado y qué debería mirar el usuario.

## Alcance

- análisis OLAP sobre jerarquías
- drill-down y drill-up
- drill-through hacia páginas de detalle
- tooltips de negocio
- contexto de filtro
- identificación de hallazgos
- estructura básica de storytelling BI
- validación SQL de hallazgos

## Prácticas que la componen

- [SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md](powerbi/SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md)

## Lógica didáctica

- el estudiante parte del modelo y las medidas de la sesión 3
- usa jerarquías para explorar ventas, margen, productos y tiempo
- aprende que cada interacción modifica el contexto de análisis
- convierte comparaciones en hallazgos
- valida hallazgos con SQL cuando corresponde
- redacta una historia breve de negocio apoyada en datos

## Resultado esperado

Al finalizar la sesión, el alumno debe tener:

- página `Exploración OLAP`
- matriz OLAP por familia, categoría y producto
- análisis temporal por año, trimestre, mes y fecha
- drill-down y drill-through funcionales
- tooltip contextual de ventas, margen y pedidos
- al menos tres hallazgos de negocio
- una mini narrativa BI con contexto, evidencia, interpretación y acción sugerida
- validación SQL de al menos un hallazgo

## Continuidad

La siguiente sesión convierte esos hallazgos en una página de dashboard:

- KPIs
- visualización base
- layout de lectura ejecutiva
- ranking de productos, clientes y vendedores
- filtros visibles
- mensajes principales del reporte
