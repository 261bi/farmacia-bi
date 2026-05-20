# Sesión U2 S3 P1: Modelo semántico en Power BI v2

## 1. Título

Construcción del modelo semántico BI en Power BI a partir del DataMart `marts`.

## 2. Objetivo

Conectar Power BI al DataMart en PostgreSQL y dejar un modelo estrella limpio, navegable y listo para construir medidas DAX.

Al finalizar la práctica, el alumno debe poder:

- conectarse a PostgreSQL desde Power BI
- cargar solo las tablas analíticas del schema `marts`
- reconocer dimensiones y tabla de hechos
- crear relaciones de uno a muchos
- identificar el grano de `fact_ventas`
- ocultar campos técnicos
- ordenar correctamente atributos temporales
- crear jerarquías de fecha y producto
- validar que el modelo responde a filtros desde dimensiones

## 3. Punto de partida

Esta práctica continúa desde el DataMart construido con dbt:

```text
MySQL -> Airbyte o Debezium -> PostgreSQL raw -> dbt staging -> dbt marts -> Power BI
```

Antes de iniciar, valida en PostgreSQL:

```sql
SELECT COUNT(*) FROM marts.fact_ventas;
SELECT COUNT(*) FROM marts.dim_fecha;
SELECT COUNT(*) FROM marts.dim_producto;
```

Tablas que se importarán:

- `marts.dim_fecha`
- `marts.dim_producto`
- `marts.dim_cliente`
- `marts.dim_vendedor`
- `marts.dim_estado_pedido`
- `marts.fact_ventas`

## 4. Conexión desde Power BI

En Power BI Desktop:

1. Selecciona `Obtener datos`.
2. Elige `Base de datos PostgreSQL`.
3. Usa:

```text
Servidor: 127.0.0.1:15432
Base de datos: farmacia_dw
Usuario: postgres
Password: postgres
```

Selecciona modo `Importar`.

No cargues tablas de:

- `raw`
- `staging`

El reporte debe consumir la capa `marts`.

## 5. Modelo estrella esperado

Tabla de hechos:

- `fact_ventas`

Dimensiones:

- `dim_fecha`
- `dim_producto`
- `dim_cliente`
- `dim_vendedor`
- `dim_estado_pedido`

Relaciones:

```text
dim_fecha[fecha_key]                 1 -> * fact_ventas[fecha_key]
dim_producto[producto_key]           1 -> * fact_ventas[producto_key]
dim_cliente[cliente_key]             1 -> * fact_ventas[cliente_key]
dim_vendedor[vendedor_key]           1 -> * fact_ventas[vendedor_key]
dim_estado_pedido[estado_pedido_key] 1 -> * fact_ventas[estado_pedido_key]
```

Configuración:

- cardinalidad: `Uno a varios`
- dirección de filtro: `Simple`
- relación activa: `Sí`

## 6. Grano de la tabla de hechos

El grano de `fact_ventas` es:

```text
una fila por línea de pedido por producto
```

Esto significa:

- un `pedido_id` puede repetirse
- un pedido puede tener varios productos
- las ventas se suman por línea
- los pedidos se cuentan con `DISTINCTCOUNT`

## 7. Campos visibles y ocultos

Oculta claves técnicas usadas para relaciones:

- `fact_ventas[fecha_key]`
- `fact_ventas[producto_key]`
- `fact_ventas[cliente_key]`
- `fact_ventas[vendedor_key]`
- `fact_ventas[estado_pedido_key]`

También puedes ocultar claves de dimensiones:

- `cliente_key`
- `producto_key`
- `vendedor_key`
- `estado_pedido_key`
- `cliente_id`
- `producto_id`
- `vendedor_id`
- `categoria_id`
- `familia_id`

Deja visibles los campos de negocio:

- `dim_fecha[fecha]`
- `dim_fecha[anio]`
- `dim_fecha[trimestre]`
- `dim_fecha[mes_desc]`
- `dim_fecha[dia_semana_desc]`
- `dim_producto[nombre_familia]`
- `dim_producto[nombre_categoria]`
- `dim_producto[nombre_producto]`
- `dim_cliente[nombre_cliente]`
- `dim_vendedor[nombre_vendedor]`
- `dim_estado_pedido[estado_pedido]`

## 8. Orden semántico de fechas

Configura `No resumir` en:

- `dim_fecha[anio]`
- `dim_fecha[trimestre]`
- `dim_fecha[mes_numero]`
- `dim_fecha[dia]`
- `dim_fecha[dia_semana_numero]`

Ordena:

```text
dim_fecha[mes_desc]         por dim_fecha[mes_numero]
dim_fecha[dia_semana_desc]  por dim_fecha[dia_semana_numero]
```

Esto evita que Power BI ordene meses o días como texto.

## 9. Jerarquías

Crea la jerarquía:

```text
Calendario
  anio
  trimestre
  mes_desc
  fecha
```

Crea la jerarquía:

```text
Producto Comercial
  nombre_familia
  nombre_categoria
  nombre_producto
```

No uses la jerarquía automática de fechas como jerarquía oficial del curso.

## 10. Validación mínima

En una página temporal, crea una tabla:

Filas:

- `dim_producto[nombre_producto]`

Valor:

- suma de `fact_ventas[venta_neta]`

Luego agrega un segmentador:

- `dim_fecha[anio]`

Resultado esperado:

- las ventas se agrupan por producto
- el filtro de año afecta la venta
- no necesitas hacer joins manuales

## 11. Evidencias a entregar

- captura de conexión a PostgreSQL
- captura de tablas `marts` importadas
- captura del modelo estrella
- captura de relaciones
- captura de jerarquía `Calendario`
- captura de jerarquía `Producto Comercial`
- captura de ordenamiento de `mes_desc` o `dia_semana_desc`
- captura de tabla de validación por producto

## 12. Cierre

Con esta práctica, Power BI queda conectado a un modelo semántico limpio. La siguiente práctica define las medidas oficiales que usarán todas las páginas del reporte.
