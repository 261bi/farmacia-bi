# Sesión U2 S2 P4: CDC, carga incremental y SCD

## 1. Título

Extensión del pipeline BI con CDC, carga incremental y tratamiento de dimensiones lentamente cambiantes.

## 2. Objetivo

Comprender cómo evoluciona un pipeline BI desde cargas batch completas hacia sincronización incremental, captura de cambios y gestión histórica de dimensiones.

Al finalizar la práctica, el alumno debe poder:

- diferenciar carga completa, carga incremental y CDC
- reconocer el rol de Debezium en la captura de cambios
- identificar eventos `insert`, `update` y `delete`
- explicar por qué una dimensión puede necesitar historial
- diferenciar SCD tipo 1 y SCD tipo 2
- validar que una carga incremental no duplique hechos

## 3. Relación con prácticas previas

Esta práctica complementa:

- [../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md](../ingesta-airbyte/SESION_U2_S2_P1_AIRBYTE_REPLICA_MYSQL_POSTGRES.md)
- [../dw-dbt/SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md](../dw-dbt/SESION_U2_S2_P2_DBT_MODELADO_FISICO_DATAMART.md)
- [../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)

La ruta principal de clase usa Airbyte y dbt. Esta práctica explica el salto conceptual hacia pipelines incrementales y CDC.

## 4. Conceptos clave

### 4.1 Carga completa

La carga completa reconstruye el destino desde cero o reemplaza todo el conjunto de datos.

Ventajas:

- fácil de entender
- fácil de validar
- útil con volúmenes pequeños

Limitaciones:

- puede ser lenta
- consume más recursos
- no escala bien cuando el origen crece

### 4.2 Carga incremental

La carga incremental mueve solo registros nuevos o modificados desde la última ejecución.

Requiere:

- campo de fecha de modificación
- clave estable
- control de última carga
- lógica para evitar duplicados

### 4.3 CDC

CDC significa `Change Data Capture`.

En lugar de preguntar periódicamente qué cambió, CDC lee los cambios del origen para capturar eventos transaccionales.

Eventos típicos:

- `insert`
- `update`
- `delete`

En el proyecto existe una carpeta de apoyo:

- [README.md](README.md)

Allí se ubica el laboratorio con Debezium, conectores y scripts de registro.

## 5. Arquitectura conceptual

```text
MySQL OLTP -> Debezium -> Stream de cambios -> PostgreSQL raw -> dbt -> marts
```

Comparación con Airbyte batch:

```text
MySQL OLTP -> Airbyte batch -> PostgreSQL raw -> dbt -> marts
```

Ambas rutas pueden alimentar un DW. La diferencia principal está en la frecuencia, granularidad y forma de detectar cambios.

## 6. Carga incremental en dbt

En dbt, un modelo incremental evita reconstruir todo el destino en cada ejecución.

Idea conceptual:

```sql
SELECT *
FROM fuente
WHERE updated_at > (SELECT MAX(updated_at) FROM destino)
```

En un modelo real se debe considerar:

- claves únicas
- estrategia de merge o append
- registros actualizados
- registros eliminados
- reejecuciones idempotentes

Regla:

```text
ejecutar dos veces el mismo pipeline no debe duplicar datos
```

## 7. SCD tipo 1

SCD tipo 1 sobrescribe el valor anterior.

Ejemplo:

```text
Cliente cambia de distrito
Dimensión conserva solo el distrito actual
```

Uso:

- cuando no importa conservar historia
- cuando el dato anterior era un error
- cuando negocio solo analiza estado actual

## 8. SCD tipo 2

SCD tipo 2 conserva historia creando una nueva versión de la fila.

Campos típicos:

- clave surrogate
- clave natural
- fecha_inicio
- fecha_fin
- es_actual

Ejemplo:

```text
cliente_id | distrito | fecha_inicio | fecha_fin   | es_actual
10         | Centro   | 2026-01-01   | 2026-03-31  | false
10         | Norte    | 2026-04-01   | null        | true
```

Uso:

- cuando se necesita analizar hechos según la versión vigente de la dimensión
- cuando el cambio de atributo tiene significado de negocio

## 9. Aplicación al caso farmacia

Dimensiones candidatas a SCD tipo 1:

- `dim_producto` cuando se corrige una descripción mal escrita
- `dim_cliente` cuando se corrige un dato de contacto

Dimensiones candidatas a SCD tipo 2:

- `dim_cliente` si cambia segmento, zona o distrito comercial
- `dim_vendedor` si cambia zona asignada
- `dim_producto` si cambia familia o categoría comercial y se desea conservar historia analítica

Hechos:

- `fact_ventas` no debe duplicarse en cargas incrementales
- la clave del pedido o línea de pedido debe permitir identificar el grano

## 10. Validaciones mínimas

### 10.1 Validar duplicados en el hecho

```sql
SELECT
    pedido_id,
    producto_id,
    COUNT(*) AS repeticiones
FROM marts.fact_ventas
GROUP BY pedido_id, producto_id
HAVING COUNT(*) > 1;
```

Si el grano oficial incluye línea de pedido, usa la clave correspondiente a esa línea.

### 10.2 Validar última fecha de carga

```sql
SELECT MAX(fecha) AS ultima_fecha
FROM marts.dim_fecha;
```

### 10.3 Validar dimensión actual en SCD tipo 2

```sql
SELECT cliente_id, COUNT(*) AS versiones_actuales
FROM marts.dim_cliente
WHERE es_actual = true
GROUP BY cliente_id
HAVING COUNT(*) > 1;
```

Esta consulta aplica si la dimensión se modela con SCD tipo 2.

## 11. Evidencias a entregar

- explicación breve de carga completa, incremental y CDC
- diagrama simple del pipeline con CDC
- ejemplo de SCD tipo 1 aplicado al caso
- ejemplo de SCD tipo 2 aplicado al caso
- consulta SQL para validar duplicados en el hecho
- consulta SQL para validar registros actuales en una dimensión SCD2

## 12. Cierre

Esta práctica conecta el laboratorio batch de la unidad con escenarios BI más exigentes. CDC, incrementalidad y SCD no reemplazan el modelo estrella; lo fortalecen para mantener el DW actualizado y conservar historia cuando negocio lo necesita.
