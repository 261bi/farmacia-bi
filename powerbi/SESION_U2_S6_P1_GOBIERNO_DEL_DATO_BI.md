# Sesión U2 S6 P1: Gobierno del dato en BI

## 1. Título

Gobierno del dato aplicado al dashboard de ventas de farmacia.

## 2. Objetivo

Documentar y gobernar el producto BI para que sus datos, métricas y visuales sean confiables, trazables y entendibles.

Al finalizar la sesión, el alumno debe poder:

- explicar qué es gobierno del dato
- diferenciar gobierno del dato de calidad de datos
- describir el linaje del caso farmacia
- construir un glosario mínimo de negocio
- documentar tablas principales
- documentar métricas críticas
- proponer reglas de calidad
- reconocer riesgos de seguridad y acceso
- preparar una ficha de gobierno del tablero

## 3. Relación con sesiones previas

Esta sesión continúa desde:

- [SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md](SESION_U2_S5_P1_DASHBOARD_KPIS_VISUALIZACION_BI.md)
- [SESION_U2_S5_P2_DASHBOARD_KPIS_VISUALIZACION_BI.md](SESION_U2_S5_P2_DASHBOARD_KPIS_VISUALIZACION_BI.md)

Hasta este punto el estudiante ya construyó:

- modelo semántico
- medidas DAX
- exploración OLAP
- progresión temporal
- storytelling
- dashboard con KPIs base
- KPI comparativo con variación

Ahora la pregunta es:

```text
¿Cómo aseguro que este BI sea confiable para una organización?
```

## 4. Qué es gobierno del dato

Gobierno del dato es el conjunto de responsabilidades, reglas y controles que aseguran que los datos se usen correctamente.

En BI responde:

- ¿de dónde viene el dato?
- ¿quién es responsable?
- ¿qué significa cada métrica?
- ¿cómo se calcula?
- ¿qué calidad tiene?
- ¿quién puede verlo?
- ¿cuándo fue actualizado?
- ¿qué limitaciones tiene?

## 5. Gobierno vs calidad

Calidad de datos revisa el estado del dato:

- completitud
- unicidad
- consistencia
- validez
- oportunidad

Gobierno del dato define cómo se gestiona:

- responsables
- reglas
- documentación
- permisos
- validaciones
- ciclo de vida

Ejemplo:

```text
Calidad: venta_neta no debe ser negativa.
Gobierno: Comercial aprueba la regla, dbt la valida y BI documenta el impacto.
```

## 6. Roles

| Rol | Responsabilidad |
| --- | --- |
| Data Owner | Define significado y uso de los datos de negocio |
| Data Steward | Mantiene glosario, reglas y calidad |
| Data Engineer | Mantiene ingesta, raw, staging y marts |
| BI Developer | Mantiene modelo semántico, medidas y visuales |
| Usuario de negocio | Interpreta el tablero y toma decisiones |

## 7. Linaje del dato

Linaje del caso farmacia:

```text
MySQL farmadb
  -> Airbyte o Debezium/Kafka
  -> PostgreSQL raw
  -> dbt staging
  -> dbt marts
  -> Power BI modelo semántico
  -> medidas DAX
  -> visuales y KPIs
```

Ejemplo para `[Ventas Netas]`:

```text
Origen: pedido_detalles en MySQL
Ingesta: Airbyte replica datos por lote o Debezium replica cambios hacia PostgreSQL raw
Staging: stg_pedido_detalles normaliza campos
DataMart: fact_ventas calcula venta_neta
Power BI: [Ventas Netas] suma fact_ventas[venta_neta]
Visual: tarjetas, tendencias, rankings y KPI comparativo
```

## 8. Glosario mínimo

| Término | Definición |
| --- | --- |
| Venta neta | Importe vendido después de descuentos |
| Pedido | Orden de compra registrada por un cliente |
| Línea de venta | Producto específico dentro de un pedido |
| Unidades vendidas | Cantidad total de productos vendidos |
| Ticket promedio | Venta neta dividida entre pedidos |
| Categoría | Agrupación comercial de productos |
| Familia | Agrupación superior de categorías |
| Variación de ventas | Diferencia entre venta actual y venta de referencia |
| % Variación de ventas | Variación dividida entre venta de referencia |

Opcional:

- venta bruta
- descuento
- margen bruto
- porcentaje de margen

## 9. Catálogo mínimo

| Tabla | Tipo | Grano | Uso |
| --- | --- | --- | --- |
| `fact_ventas` | Hecho | Línea de pedido por producto | Ventas, pedidos, unidades, ticket |
| `dim_fecha` | Dimensión | Fecha | Año, trimestre, mes, día |
| `dim_producto` | Dimensión | Producto | Familia, categoría y producto |
| `dim_cliente` | Dimensión | Cliente | Ranking y detalle de clientes |
| `dim_vendedor` | Dimensión | Vendedor | Ranking de vendedores |
| `dim_estado_pedido` | Dimensión | Estado | Filtro de estado del pedido |

## 10. Métricas gobernadas

Documenta como obligatorias:

| Métrica | Fórmula | Formato | Dueño |
| --- | --- | --- | --- |
| `[Ventas Netas]` | `SUM(fact_ventas[venta_neta])` | Moneda | Comercial |
| `[Pedidos]` | `DISTINCTCOUNT(fact_ventas[pedido_id])` | Entero | Comercial |
| `[Unidades Vendidas]` | `SUM(fact_ventas[cantidad_vendida])` | Entero | Comercial |
| `[Ticket Promedio]` | `DIVIDE([Ventas Netas], [Pedidos])` | Moneda | Comercial |
| `[% Variación Ventas]` | `DIVIDE([Variación Ventas], [Ventas Año Previo Mismo Periodo])` | Porcentaje | Comercial |

Opcional:

- `[Ventas Brutas]`
- `[Descuentos]`
- `[Margen Bruto]`
- `[% Margen Bruto]`

Regla:

```text
Si una métrica aparece en el dashboard, debe estar definida y validada.
```

## 11. Reglas de calidad

### 11.1 Hecho

```sql
SELECT COUNT(*) AS filas_sin_pedido
FROM marts.fact_ventas
WHERE pedido_id IS NULL;
```

```sql
SELECT pedido_id, producto_id, COUNT(*) AS repeticiones
FROM marts.fact_ventas
GROUP BY pedido_id, producto_id
HAVING COUNT(*) > 1;
```

```sql
SELECT COUNT(*) AS ventas_negativas
FROM marts.fact_ventas
WHERE venta_neta < 0;
```

### 11.2 Dimensiones

```sql
SELECT COUNT(*) AS productos_sin_nombre
FROM marts.dim_producto
WHERE nombre_producto IS NULL;
```

```sql
SELECT fecha_key, COUNT(*) AS repeticiones
FROM marts.dim_fecha
GROUP BY fecha_key
HAVING COUNT(*) > 1;
```

### 11.3 Integridad referencial

```sql
SELECT COUNT(*) AS hechos_sin_producto
FROM marts.fact_ventas fv
LEFT JOIN marts.dim_producto dp
    ON fv.producto_key = dp.producto_key
WHERE dp.producto_key IS NULL;
```

## 12. Seguridad y acceso

Preguntas mínimas:

- ¿quién puede ver ventas totales?
- ¿quién puede ver detalle por cliente?
- ¿un vendedor debe ver solo sus ventas?
- ¿qué campos deben ocultarse?
- ¿qué se puede exportar?

Riesgos:

- exposición de nombres de clientes
- exportación de detalle innecesario
- uso de métricas no oficiales
- decisiones tomadas con datos no actualizados

## 13. Ficha de gobierno del tablero

Completa:

```text
Nombre del tablero:
Objetivo:
Usuarios:
Fuente principal:
Linaje:
Dueño funcional:
Responsable BI:
Frecuencia de actualización:
Tabla de hechos:
Grano:
Dimensiones:
Métricas críticas:
Reglas de calidad:
Datos sensibles:
Restricciones de acceso:
Limitaciones:
```

## 14. Actividad de clase

Entregables:

1. Mapa de linaje de `[Ventas Netas]`.
2. Glosario con al menos ocho términos.
3. Diccionario de cinco métricas.
4. Tres reglas de calidad SQL.
5. Ficha de gobierno del tablero.

## 15. Preguntas para discusión

- ¿Qué pasa si dos reportes calculan ventas netas distinto?
- ¿Quién aprueba la definición oficial de ticket promedio?
- ¿Qué métrica no debería improvisarse en un visual?
- ¿Qué campos del cliente deberían protegerse?
- ¿Cómo sabemos si la ingesta, dbt y Power BI están alineados?
- ¿Qué evidencia pediría un gerente antes de confiar en el dashboard?

## 16. Evidencias a entregar

- mapa de linaje
- glosario de negocio
- catálogo mínimo
- diccionario de métricas
- reglas de calidad
- ficha de gobierno
- propuesta de seguridad o acceso

## 17. Cierre

BI no termina en un dashboard. Termina cuando el dato puede ser explicado, validado, protegido y usado para decidir.
