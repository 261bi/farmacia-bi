# Power BI

## Proposito

Esta carpeta queda reservada para la capa de consumo analitico del proyecto.

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
- documentacion del dashboard final

## Validacion minima

Antes de conectar Power BI, valida que en PostgreSQL existan:

```sql
\dt marts.*
select * from marts.fact_ventas limit 20;
```

## Integracion

- consume la salida final de `dw-dbt/`
- representa la capa final de analisis y visualizacion del proyecto

## Guias relacionadas

- [../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)
