# Power BI

## Propósito

Esta carpeta queda reservada para la capa de consumo analítico del proyecto.

## Rol en la arquitectura

```text
MySQL -> Airbyte o Debezium -> PostgreSQL -> dbt -> Power BI
```

## Fuente principal

Power BI debe consumir principalmente el modelo estrella final construido en PostgreSQL:

- base: `farmacia_dw`
- schema principal: `marts`

Tablas esperadas:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

## Contenido esperado

En esta carpeta pueden vivir:

- archivo `.pbix`
- mockups
- capturas
- medidas DAX
- documentación del dashboard final

## Sesión U2 S3

Esta carpeta contiene la tercera sesión macro de la Unidad 2:

- [SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md](SESION_U2_S3_P1_MODELO_SEMANTICO_POWER_BI.md)
- [SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md](SESION_U2_S3_P2_MEDIDAS_DAX_Y_AGREGACIONES.md)
- [medidas_farmacia_bi.dax](medidas_farmacia_bi.dax)

Nota:

- los archivos con sufijo `_vAnterior` se conservan temporalmente como referencia historica
- la ruta oficial de clase usa los archivos sin sufijo

## Sesión U2 S4

Exploración OLAP, hallazgos y storytelling BI:

- [SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md](SESION_U2_S4_P1_EXPLORACION_OLAP_STORYTELLING_POWER_BI.md)

## Sesión U2 S5

Dashboard BI con KPIs y visualización base:

- [SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md](SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md)
- [SESION_U2_S5_P2_DASHBOARD_KPIS_VISUALIZACION_BI.md](SESION_U2_S5_P2_DASHBOARD_KPIS_VISUALIZACION_BI.md)

## Sesión U2 S6

Gobierno del dato en BI:

- [SESION_U2_S6_P1_GOBIERNO_DEL_DATO_BI.md](SESION_U2_S6_P1_GOBIERNO_DEL_DATO_BI.md)

## Sesión U2 S7

Evaluación integral de la Unidad 2:

- [SESION_U2_S7_P1_EVALUACION_U2_BI_END_TO_END.md](SESION_U2_S7_P1_EVALUACION_U2_BI_END_TO_END.md)

## Validación mínima

Antes de conectar Power BI, valida que en PostgreSQL existan:

```sql
\dt marts.*
select * from marts.fact_ventas limit 20;
```

## Integración

- consume la salida final de `dw-dbt/`
- representa la capa final de análisis y visualización del proyecto

## Guías relacionadas

- [../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)
- [../UNIDAD_2_SESION_3.md](../UNIDAD_2_SESION_3.md)
- [../UNIDAD_2_SESION_4.md](../UNIDAD_2_SESION_4.md)
- [../UNIDAD_2_SESION_5.md](../UNIDAD_2_SESION_5.md)
- [../UNIDAD_2_SESION_6.md](../UNIDAD_2_SESION_6.md)
- [../UNIDAD_2_SESION_7.md](../UNIDAD_2_SESION_7.md)
