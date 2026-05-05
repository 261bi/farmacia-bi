# Unidad 2 - Sesión 1

## Sesión 6 - Implementación manual del DW con SQL

Este documento deja congelada la primera sesión macro de la Unidad 2 para el siguiente semestre.

## Alcance

- ETL manual
- transformación
- carga
- validación analítica

## Prácticas que la componen

- [SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md](oltp-mysql/SESION_U2_S1_P1_IMPLEMENTACION_FISICA_MANUAL_DEL_DATAMART_DENTRO_DEL_MISMO_OLTP.md)
- [SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md](oltp-mysql/SESION_U2_S1_P2_ETL_MANUAL_CON_SQL_PARA_DIMENSIONES_Y_HECHO_MEDIANTE_LA_VISTA_G.md)
- [SESION_U2_S1_P3_VALIDACION_ANALITICA_DEL_DATAMART_MANUAL.md](oltp-mysql/SESION_U2_S1_P3_VALIDACION_ANALITICA_DEL_DATAMART_MANUAL.md)

## Lógica didáctica

- el estudiante construye primero la estructura física del DataMart dentro del mismo OLTP
- luego entiende el ETL manual con SQL, especialmente la integración mediante la vista `G`
- finalmente valida analíticamente el resultado y reconoce las limitaciónes del enfoque manual

## Nota conceptual

En el sílabo se mantiene el término `DW` por consistencia con el enfoque institucional y con herramientas legacy.

En la implementación práctica del caso, el alumno construye específicamente el DataMart del proceso de ventas dentro de una arquitectura de DW.
