# Unidad 2 - Sesión 7

## Sesión 12 - Evaluación U2

Este documento deja congelada la séptima sesión macro de la Unidad 2 para el siguiente semestre.

La sesión corresponde al bloque:

```text
Unidad 2 - Construcción del BI
Sesión 12 - Evaluación integral de la Unidad 2
```

## Alcance

- evaluación del pipeline BI completo
- revisión del DataMart
- revisión del modelo semántico
- revisión de medidas DAX
- revisión del tablero Power BI
- validación analítica contra SQL
- sustentación técnica y funcional

## Prácticas que la componen

- [SESION_U2_S7_P1_EVALUACION_U2_BI_END_TO_END.md](powerbi/SESION_U2_S7_P1_EVALUACION_U2_BI_END_TO_END.md)

## Lógica didáctica

- el estudiante demuestra que comprende el flujo completo de construcción del BI
- explica cómo pasan los datos desde el OLTP hasta el reporte
- valida métricas del tablero contra el DataMart
- interpreta resultados de negocio desde Power BI
- reconoce límites, supuestos y mejoras posibles

## Resultado esperado

Al finalizar la evaluación, el alumno debe presentar:

- DataMart operativo en PostgreSQL
- modelo semántico Power BI conectado al schema `marts`
- medidas DAX principales creadas y formateadas
- reporte Power BI con páginas de resumen y detalle
- validaciones SQL de métricas clave
- sustentación breve del diseño técnico y analítico

## Producto evaluable

El producto final de la Unidad 2 es un BI funcional del caso farmacia:

```text
MySQL OLTP -> Airbyte -> PostgreSQL raw -> dbt staging/marts -> Power BI
```

La evaluación revisa tanto la construcción técnica como la capacidad de interpretar el resultado.
