# PLANTILLA - ENTREGABLE U2: ETL, calidad de datos y DataMart

Esta plantilla integra las actividades autónomas de las sesiones de la Unidad 2:

- S6 Implementación manual del DW/DataMart con SQL
- S7 Implementación del pipeline BI con herramientas
- S8 Modelo semántico y métricas BI

El entregable debe demostrar que el estudiante puede construir, cargar, validar y consumir analíticamente un DataMart, pasando desde el OLTP hacia una arquitectura BI más organizada.

---

## 1. Datos generales del proyecto

**Nombre del proyecto BI:**  

**Integrantes:**  

**Proceso de negocio analizado:**  

**Fuente transaccional usada:**  

**Herramientas utilizadas:**  

| Componente | Herramienta / tecnología | Evidencia |
| --- | --- | --- |
| OLTP | MySQL / otro |  |
| Ingesta | Airbyte / Debezium |  |
| DW / DataMart | PostgreSQL / otro |  |
| Transformación | dbt / SQL |  |
| Modelo semántico | Power BI |  |
| Validación | SQL / Power BI |  |

---

## 2. Contexto analítico heredado de la Unidad 1

### 2.1 Problema de negocio

Breve descripción del problema que se busca analizar con BI.

- Área o proceso involucrado:
- Decisiones que se buscan mejorar:
- Usuarios principales:

### 2.2 KPIs o métricas principales

| KPI / métrica | Definición | Fórmula | Fuente | Usuario |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

### 2.3 Modelo dimensional objetivo

**Tabla de hechos principal:**  

**Grano de la tabla de hechos:**  

**Dimensiones consideradas:**

| Dimensión | Atributos principales | Jerarquías | Fuente OLTP |
| --- | --- | --- | --- |
| Fecha |  | Día, mes, trimestre, año |  |
| Producto |  | Familia, categoría, producto |  |
| Cliente |  |  |  |
| Vendedor |  |  |  |

---

## 3. Sesión 6 - Implementación manual del DataMart con SQL

### 3.1 Diseño físico manual del DataMart

Indicar las tablas creadas manualmente para el DataMart.

| Tabla DataMart | Tipo | Descripción | Clave principal | Claves foráneas |
| --- | --- | --- | --- | --- |
| dim_fecha | Dimensión |  |  |  |
| dim_producto | Dimensión |  |  |  |
| dim_cliente | Dimensión |  |  |  |
| fact_ventas | Hecho |  |  |  |

### 3.2 Script de creación de tablas

Pegar o referenciar el script SQL usado.

```sql
-- CREATE TABLE ...
```

### 3.3 ETL manual con SQL

Describir cómo se extrajeron, transformaron y cargaron los datos.

| Etapa ETL | Descripción | Tablas origen | Tablas destino | Regla aplicada |
| --- | --- | --- | --- | --- |
| Extracción |  |  |  |  |
| Transformación |  |  |  |  |
| Carga de dimensiones |  |  |  |  |
| Carga de hechos |  |  |  |  |

### 3.4 Uso de vista o consulta integradora

Si se usó una vista general, como `G`, describir su propósito.

| Vista / consulta | Tablas que integra | Uso dentro del ETL |
| --- | --- | --- |
|  |  |  |

```sql
-- SELECT usado para integrar datos del OLTP
```

### 3.5 Evidencia de carga manual

| Tabla | Cantidad de registros esperada | Cantidad cargada | Observación |
| --- | ---: | ---: | --- |
| dim_fecha |  |  |  |
| dim_producto |  |  |  |
| dim_cliente |  |  |  |
| fact_ventas |  |  |  |

---

## 4. Sesión 7 - Pipeline BI con herramientas

En esta sesión el ETL se implementa con herramientas:

- **E - Extracción / ingesta:** Airbyte o Debezium desde la BD transaccional hacia la BD analítica.
- **T - Transformación:** dbt sobre la capa `raw` para construir modelos `staging`.
- **L - Carga analítica:** dbt materializa dimensiones y hechos en `marts`.

### 4.1 Arquitectura implementada

Representar el flujo construido.

```text
BD transaccional OLTP -> Airbyte/Debezium -> BD analítica DW -> raw -> dbt staging -> dbt marts -> Power BI
```

### 4.1.1 Separación física de bases de datos

El pipeline debe evidenciar separación entre la base transaccional y la base analítica. Pueden estar en contenedores distintos, servidores distintos o servicios distintos. El uso de Airbyte o Debezium valida esta separación porque replica o captura cambios desde una base origen hacia una base destino.

| Componente | Motor | Contenedor / servidor / servicio | Puerto | Rol |
| --- | --- | --- | --- | --- |
| BD origen OLTP | MySQL / PostgreSQL / otro |  |  | Sistema transaccional |
| Herramienta de ingesta | Airbyte / Debezium |  |  | Replicación o CDC |
| BD destino DW | PostgreSQL / otro |  |  | Base analítica |
| Transformación | dbt |  |  | Modelado `staging` y `marts` |
| Consumo BI | Power BI |  |  | Modelo semántico y métricas |

**Nota:** No se considera suficiente copiar tablas dentro de la misma base como solución de pipeline automatizado. La práctica manual de la sesión 6 puede ocurrir dentro del mismo entorno, pero la sesión 7 debe mostrar una arquitectura separada entre origen transaccional y destino analítico.

### 4.2 Ingesta de datos

| Origen | Destino | Herramienta | Modo de carga | Estado |
| --- | --- | --- | --- | --- |
| MySQL / PostgreSQL OLTP | PostgreSQL DW `raw` | Airbyte / Debezium | Completa / incremental / CDC |  |

### 4.2.1 Evidencia de Airbyte o Debezium

| Elemento | Evidencia esperada | Estado |
| --- | --- | --- |
| Conexión al origen OLTP | Captura o configuración del source |  |
| Conexión al destino DW | Captura o configuración del destination |  |
| Flujo de sincronización | Captura del connection/job |  |
| Resultado de la carga | Tablas replicadas en `raw` |  |
| Carga incremental o CDC | Evidencia de cursor, log o evento de cambio |  |

### 4.3 Capas del pipeline

| Capa | Equivalencia | Propósito | Evidencia |
| --- | --- | --- | --- |
| raw | Bronze | Datos crudos replicados desde el OLTP |  |
| staging | Silver | Modelos dbt limpiados, renombrados y estandarizados |  |
| marts | Gold | Modelos dbt dimensionales listos para análisis |  |

### 4.3.1 Proyecto dbt

Documentar la estructura mínima del proyecto dbt usado para transformar `raw` en `staging` y `marts`.

| Elemento dbt | Descripción | Evidencia |
| --- | --- | --- |
| `profiles.yml` / conexión | Conexión hacia la BD analítica |  |
| `sources.yml` | Declaración de fuentes `raw` |  |
| Modelos `staging` | Limpieza, estandarización y renombrado |  |
| Modelos `marts` | Dimensiones y hechos del DataMart |  |
| Tests dbt | `not_null`, `unique`, `relationships` u otros |  |
| Documentación dbt | Descripción de modelos y columnas |  |

### 4.4 Transformaciones dbt en staging

| Modelo / tabla staging | Origen | Transformación aplicada | Justificación |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |

### 4.5 Construcción del DataMart con dbt en marts

| Tabla marts | Tipo | Fuente staging | Regla de negocio | KPI soportado |
| --- | --- | --- | --- | --- |
| dim_fecha | Dimensión |  |  |  |
| dim_producto | Dimensión |  |  |  |
| fact_ventas | Hecho |  |  |  |

### 4.6 Materialización e incrementalidad en dbt

| Modelo dbt | Materialización | Motivo | Evidencia |
| --- | --- | --- | --- |
|  | view / table / incremental |  |  |
|  | view / table / incremental |  |  |
|  | view / table / incremental |  |  |

### 4.7 Carga incremental, CDC u optimización

Completar según lo implementado en la práctica.

| Mecanismo | ¿Se implementó? | Descripción | Evidencia |
| --- | --- | --- | --- |
| Carga incremental | Sí / No |  |  |
| CDC con Debezium o equivalente | Sí / No |  |  |
| Índices / optimización | Sí / No |  |  |

**Nota sobre SCD:** SCD se revisa solo como referencia conceptual de modelado dimensional. En esta versión del laboratorio no se exige implementar dimensiones históricas.

---

## 5. Calidad de datos y validación analítica

La validación debe entenderse como un solo bloque de control, aplicado en varios niveles del pipeline.

| Nivel de validación | Qué se valida | Evidencia esperada |
| --- | --- | --- |
| OLTP vs `raw` | Que la ingesta conserve registros y campos principales | Conteos, totales o log de Airbyte/Debezium |
| `raw` vs `staging` | Que dbt limpie, renombre y estandarice sin perder información crítica | Consultas SQL o modelos dbt |
| `staging` vs `marts` | Que dimensiones y hechos se construyan con claves, grano y reglas correctas | Consultas SQL, `dbt run`, `dbt test` |
| DataMart analítico | Que los KPIs calculados en SQL respondan al negocio | Consultas agregadas sobre `marts` |
| Power BI vs SQL | Que las medidas DAX coincidan con los resultados del DataMart | Tabla comparativa SQL vs Power BI |

### 5.1 Controles de calidad aplicados

| Control | Tabla / campo | Regla esperada | Resultado | Estado |
| --- | --- | --- | --- | --- |
| Completitud |  | No debe tener nulos críticos |  |  |
| Unicidad |  | Claves sin duplicados |  |  |
| Integridad referencial |  | FK válidas entre hecho y dimensiones |  |  |
| Consistencia |  | Montos y cantidades coherentes |  |  |
| Rango válido |  | Fechas, precios o cantidades dentro de rango |  |  |

### 5.2 Validación de dimensiones

```sql
-- Consultas de validación de dimensiones
```

| Dimensión | Validación realizada | Resultado | Observación |
| --- | --- | --- | --- |
| dim_fecha |  |  |  |
| dim_producto |  |  |  |
| dim_cliente |  |  |  |

### 5.3 Validación de tabla de hechos

```sql
-- Consultas de validación de la tabla de hechos
```

| Validación | Consulta / criterio | Resultado | Observación |
| --- | --- | --- | --- |
| Total de registros |  |  |  |
| Total de ventas |  |  |  |
| Total de unidades |  |  |  |
| Integridad con dimensiones |  |  |  |

### 5.4 Comparación OLTP vs DataMart

| Métrica | Resultado OLTP | Resultado DataMart | Diferencia | ¿Coincide? |
| --- | ---: | ---: | ---: | --- |
| Ventas totales |  |  |  | Sí / No |
| Cantidad de pedidos |  |  |  | Sí / No |
| Unidades vendidas |  |  |  | Sí / No |
| Margen |  |  |  | Sí / No |

### 5.5 Hallazgos de calidad de datos

Registrar errores, inconsistencias o limitaciones encontradas.

| Hallazgo | Impacto analítico | Acción tomada | Estado final |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |

---

## 6. Sesión 8 - Modelo semántico y métricas BI

### 6.1 Conexión del DataMart a Power BI

| Elemento | Descripción |
| --- | --- |
| Motor de datos |  |
| Base de datos |  |
| Schema usado | marts |
| Modo de conexión | Import / DirectQuery |
| Tablas importadas |  |

### 6.2 Relaciones del modelo semántico

| Tabla dimensión | Tabla hecho | Campo dimensión | Campo hecho | Cardinalidad | Dirección de filtro |
| --- | --- | --- | --- | --- | --- |
| dim_fecha | fact_ventas |  |  | 1:* |  |
| dim_producto | fact_ventas |  |  | 1:* |  |
| dim_cliente | fact_ventas |  |  | 1:* |  |

### 6.3 Jerarquías OLAP creadas

| Jerarquía | Niveles | Tabla | Uso analítico |
| --- | --- | --- | --- |
| Calendario | Año, trimestre, mes, día | dim_fecha | Análisis temporal |
| Producto | Familia, categoría, producto | dim_producto | Análisis comercial |
|  |  |  |  |

### 6.4 Medidas DAX implementadas

| Medida | Fórmula DAX | Formato | KPI asociado |
| --- | --- | --- | --- |
| Total Ventas |  | Moneda |  |
| Total Unidades |  | Entero |  |
| Margen |  | Moneda |  |
| % Margen |  | Porcentaje |  |

```DAX
-- Pegar aquí las medidas principales
```

### 6.5 Validación SQL vs Power BI

| Métrica | Resultado SQL DataMart | Resultado Power BI | Diferencia | Observación |
| --- | ---: | ---: | ---: | --- |
| Total Ventas |  |  |  |  |
| Total Unidades |  |  |  |  |
| Margen |  |  |  |  |
| % Margen |  |  |  |  |

### 6.6 Evidencia visual del modelo

Agregar capturas o enlaces de:

- Modelo de relaciones en Power BI
- Medidas DAX creadas
- Jerarquías creadas
- Tabla o matriz de prueba
- Comparación contra SQL

---

## 7. Evidencias obligatorias del entregable

Las evidencias son una condición transversal del producto. Deben sustentar todos los criterios de la rúbrica.

| Evidencia | Formato sugerido | Estado |
| --- | --- | --- |
| Script SQL de creación manual del DataMart | `.sql` / captura |  |
| Script SQL de ETL manual | `.sql` / captura |  |
| Evidencia de separación OLTP y DW | captura de contenedores, servidores o conexiones |  |
| Evidencia de ingesta con Airbyte o Debezium | captura / log / job / evento CDC |  |
| Proyecto dbt | carpeta del proyecto / repositorio / captura |  |
| `sources.yml` y modelos staging | archivos dbt / capturas |  |
| Modelos marts en dbt | archivos dbt / capturas |  |
| Tests dbt ejecutados | captura / log de `dbt test` |  |
| Consultas de validación de calidad | `.sql` / captura |  |
| Comparación OLTP vs DataMart | tabla / captura |  |
| Archivo Power BI conectado al DataMart | `.pbix` |  |
| Captura del modelo semántico | imagen |  |
| Medidas DAX documentadas | tabla / captura |  |
| Validación SQL vs Power BI | tabla / captura |  |

---

## 8. Conclusiones

Responder brevemente:

1. ¿El DataMart construido soporta los KPIs definidos en la Unidad 1?
2. ¿Cómo se evidencia la separación entre OLTP y DW/DataMart?
3. ¿Qué diferencia existe entre el ETL manual y el pipeline con Airbyte/Debezium + dbt?
4. ¿Qué problemas de calidad de datos se encontraron?
5. ¿Las medidas de Power BI coinciden con las consultas SQL del DataMart?
6. ¿Qué limitaciones tiene la solución actual?

---

## 9. Participación individual del equipo

Cada integrante debe registrar sus aportes principales y la evidencia asociada.

| Integrante | Actividades realizadas | Sesión / componente | Evidencia | Autoevaluación breve |
| --- | --- | --- | --- | --- |
|  |  | Sesión 6 / Sesión 7 / Sesión 8 |  |  |
|  |  | Sesión 6 / Sesión 7 / Sesión 8 |  |  |
|  |  | Sesión 6 / Sesión 7 / Sesión 8 |  |  |

---

# Rúbrica de Evaluación del Producto de la Unidad 2

**Nota:** Las herramientas usadas en clase son Airbyte/Debezium, dbt, PostgreSQL y Power BI. Los equipos pueden usar herramientas equivalentes, siempre que evidencien el mismo rol dentro del pipeline: ingesta, transformación, carga analítica, modelo semántico y consumo BI.

| Criterio | Sesión evaluada | N3 - Logro alto | N2 - Esperado | N1 - En proceso | N0 - Deficiente |
| --- | --- | --- | --- | --- | --- |
| 1. ETL manual y DataMart inicial con SQL | Sesión 6 | Implementa manualmente dimensiones y hechos, carga datos con SQL y documenta grano, claves, transformación, carga y validación analítica | Implementa el DataMart manual con errores menores o documentación parcial | DataMart o ETL manual incompleto, con relaciones o cargas poco claras | No implementa DataMart manual ni ETL SQL |
| 2. Extracción / ingesta con herramientas | Sesión 7 | Evidencia separación OLTP-DW en contenedores, servidores o servicios distintos, e ingesta funcional con Airbyte, Debezium o herramienta equivalente hacia `raw`, incluyendo carga incremental o CDC cuando corresponda | La ingesta funciona, pero la evidencia de separación, sincronización incremental o CDC es parcial | La ingesta es incompleta, poco verificable o no llega claramente a `raw` | No implementa ingesta con Airbyte/Debezium ni herramienta equivalente |
| 3. Transformación, carga analítica y optimización con dbt | Sesión 7 | Usa dbt o herramienta equivalente correctamente para `sources`, `staging` y `marts`, materializando dimensiones/hechos, carga incremental u optimización cuando corresponde | Construye `staging` y `marts`, pero con documentación, materializaciones, incrementalidad u optimización incompletas | Proyecto de transformación parcial, desordenado o con reglas poco justificadas | No usa dbt ni herramienta equivalente para transformar y cargar el DataMart |
| 4. Modelo semántico y métricas BI | Sesión 8 | Construye en Power BI o herramienta equivalente relaciones, cardinalidades, jerarquías OLAP, medidas y agregaciones coherentes con el DataMart y los KPIs | Modelo semántico funcional con errores menores en relaciones, jerarquías, medidas o agregaciones | Modelo incompleto o con medidas poco confiables | No presenta modelo semántico ni medidas BI |
| 5. Validación multinivel y calidad de datos | Sesiones 6, 7 y 8 | Valida calidad, integridad y resultados en varios niveles: OLTP vs `raw`, `raw` vs `staging`, `staging` vs `marts`, SQL analítico y Power BI | Valida los niveles principales, pero con cobertura o explicación parcial | Validación superficial, limitada a conteos o capturas aisladas | No valida calidad ni resultados analíticos |
| 6. Participación individual del equipo | Transversal | Cada integrante evidencia aportes claros, verificables y equilibrados en construcción, validación, documentación o exposición | La mayoría de integrantes evidencia aportes, con distribución parcialmente equilibrada | Participación desigual o poco verificable entre integrantes | No se evidencia participación individual o el trabajo recae en una sola persona |
