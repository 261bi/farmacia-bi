# Unidad 2 - Sesion 2

## Sesion 7 - Implementacion del pipeline BI con herramientas

Este documento deja congelada la segunda sesion macro de la Unidad 2 para el siguiente semestre.

## Alcance

- ingesta
- transformacion
- carga
- optimizacion

## Practicas que la componen

- `SESION_U2_S2_P1_INGESTA_BATCH_CON_AIRBYTE_DE_MYSQL_A_POSTGRESQL.md`
- `SESION_U2_S2_P2_IMPLEMENTACION_DE_STAGING_CON_DBT_EN_POSTGRESQL.md`
- `SESION_U2_S2_P3_IMPLEMENTACION_DEL_DATAMART_CON_DBT_EN_POSTGRESQL.md`

## Logica didactica

- el estudiante separa OLTP y DW
- usa Airbyte para la ingesta batch hacia PostgreSQL
- usa dbt para construir la capa `staging`
- finalmente implementa el DataMart en `marts`

## Nota conceptual

Esta sesion representa el paso desde un enfoque manual hacia un pipeline BI mas mantenible, trazable y escalable.
