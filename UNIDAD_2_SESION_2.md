# Unidad 2 - Sesion 2

## Sesion 7 - Implementacion del pipeline BI con herramientas

Este documento deja congelada la segunda sesion macro de la Unidad 2 para el siguiente semestre.

## Alcance

- ingesta
- transformacion
- carga
- optimizacion

## Practicas que la componen

- [SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
- [SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](dw-dbt/SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)
- [SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)

## Logica didactica

- el estudiante separa OLTP y DW
- usa Airbyte para la ingesta batch hacia PostgreSQL
- usa dbt para construir la capa `staging`
- finalmente implementa el DataMart en `marts`

## Nota conceptual

Esta sesion representa el paso desde un enfoque manual hacia un pipeline BI mas mantenible, trazable y escalable.

En muchos materiales externos esta arquitectura se explica como capas:

- `Bronze`: datos crudos
- `Silver`: datos limpiados y estandarizados
- `Gold`: datos listos para analisis de negocio

En este curso, la equivalencia practica sera:

- `raw` = `Bronze`
- `staging` = `Silver`
- `marts` = `Gold`
