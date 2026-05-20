# Unidad 2 - Sesión 6

## Sesión 11 - Gobierno del dato en BI

Este documento deja congelada la sexta sesión macro de la Unidad 2.

La sesión corresponde al bloque:

```text
Unidad 2 - Construcción del BI
Sesión 11 - Gobierno del dato: calidad, linaje, catálogo, seguridad y métricas gobernadas
```

## Por qué esta sesión cambia

La sesión 3 ya trabajó modelo semántico, medidas y agregaciones. La sesión 5 ya construyó la página de KPIs. Repetir validación, formatos y limpieza del modelo en la sesión 6 aporta poco.

El cierre más valioso para una unidad de construcción BI es Gobierno del dato. Ahí el estudiante entiende por qué un tablero no es confiable solo porque se ve bien:

- debe tener definiciones comunes
- debe tener responsables
- debe mostrar trazabilidad
- debe cuidar calidad
- debe proteger datos sensibles
- debe evitar métricas duplicadas o contradictorias
- debe ser mantenible

## Alcance

- concepto de Data Governance
- diferencia entre gobierno del dato y calidad de datos
- roles: owner, steward, consumidor, equipo BI
- linaje del dato desde OLTP hasta Power BI
- catálogo de datos y glosario de negocio
- reglas de calidad
- gobierno de métricas DAX
- seguridad, privacidad y acceso
- documentación mínima del producto BI
- aplicación al caso farmacia

## Prácticas que la componen

- [SESION_U2_S6_P1_GOBIERNO_DEL_DATO_BI.md](powerbi/SESION_U2_S6_P1_GOBIERNO_DEL_DATO_BI.md)

## Lógica didáctica

- el estudiante ya construyó un flujo BI funcional
- ahora aprende a gobernarlo
- identifica dónde puede romperse la confianza del dato
- define responsables y reglas mínimas
- documenta métricas y fuentes
- reconoce riesgos de seguridad y privacidad
- prepara argumentos para sustentar el BI en la evaluación

## Resultado esperado

Al finalizar la sesión, el alumno debe entregar:

- mapa de linaje del dato del caso farmacia
- glosario mínimo de negocio
- catálogo simple de tablas principales
- matriz de roles y responsabilidades
- reglas de calidad para `fact_ventas` y dimensiones
- diccionario de medidas BI
- criterios de seguridad y acceso
- ficha de gobierno del tablero

## Continuidad

La siguiente sesión es la evaluación integral de la Unidad 2:

```text
OLTP -> Ingesta -> DW/DataMart -> Modelo semántico -> OLAP -> Storytelling -> Dashboard -> Gobierno del dato
```
