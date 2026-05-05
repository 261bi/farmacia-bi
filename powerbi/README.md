# Power BI

## Propósito

Esta carpeta queda reservada para la capa de consumo analítico del proyecto.

## Rol en la arquitectura

```text
MySQL -> Airbyte -> PostgreSQL -> dbt -> Power BI
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

## Sesión U2 S4

Esta carpeta también contiene el inicio de la visualización BI base:

- [SESION_U2_S4_P1_VISUALIZACION_BI_BASE.md](SESION_U2_S4_P1_VISUALIZACION_BI_BASE.md)

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
