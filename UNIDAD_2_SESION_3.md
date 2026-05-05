# Unidad 2 - Sesión 3

## Sesión 8 - Modelo semántico y métricas BI

Este documento deja congelada la tercera sesión macro de la Unidad 2 para el siguiente semestre.

## Alcance

- modelo semántico
- relaciones
- jerarquías OLAP
- medidas BI
- agregaciones
- consumo analítico

## Prácticas que la componen

- [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](powerbi/SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)
- [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](powerbi/SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)

## Lógica didáctica

- el estudiante parte del DataMart ya poblado en PostgreSQL
- conecta Power BI directamente al schema `marts`
- convierte la estrella física en un modelo semántico navegable
- define jerarquías para analizar por tiempo y producto
- implementa medidas DAX sobre el hecho `fact_ventas`
- valida que las agregaciones respondan correctamente a los filtros y dimensiones

## Nota conceptual

La sesión anterior dejó construido y validado el DataMart físico.

Esta sesión ya no modifica el pipeline `raw -> staging -> marts`; se concentra en la capa de consumo analítico:

```text
PostgreSQL marts -> Power BI -> Modelo semántico -> Medidas -> Reporte
```

En términos BI:

- `marts.fact_ventas` aporta los hechos y medidas base
- `marts.dim_*` aporta los ejes de análisis
- Power BI organiza relaciones, jerarquías y medidas de negocio
- el usuario final consume KPIs, tablas dinámicas, gráficos y filtros

## Resultado esperado

Al finalizar la sesión, el alumno debe tener un archivo Power BI conectado al DataMart con:

- tablas importadas desde `marts`
- relaciones uno-a-muchos desde dimensiones hacia el hecho
- jerarquía calendario
- jerarquía comercial de producto
- medidas DAX principales
- validación cruzada contra consultas SQL del DataMart

## Continuidad

La visualización base con KPIs, filtros y primeras páginas de reporte continúa en la siguiente sesión:

- `Sesión 4 - Visualización BI base`
