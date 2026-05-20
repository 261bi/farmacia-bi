# Sesión U2 S3 P1: Modelo semántico en Power BI

## 1. Título

Construcción del modelo semántico BI a partir del DataMart `marts` en PostgreSQL.

## 2. Objetivo

Conectar Power BI al DataMart ya construido y convertir el modelo estrella físico en un modelo semántico listo para análisis.

Al finalizar la práctica, el alumno debe poder:

- conectarse a PostgreSQL desde Power BI
- importar las tablas del schema `marts`
- reconocer la tabla de hechos y las dimensiones
- crear relaciones entre dimensiones y hecho
- configurar tipos de datos, formatos y visibilidad de columnas
- construir jerarquías OLAP 

## 3. Punto de partida

Esta práctica continúa directamente desde:

- [../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md](../dw-dbt/SESION_U2_S2_P3_VALIDACION_ANALITICA_DEL_DATAMART.md)

Antes de iniciar, valida que el DataMart existe:

```sql
\dt marts.*
SELECT * FROM marts.fact_ventas LIMIT 20;
```

Tablas esperadas:

- `marts.dim_cliente`
- `marts.dim_vendedor`
- `marts.dim_producto`
- `marts.dim_fecha`
- `marts.dim_estado_pedido`
- `marts.fact_ventas`

## 4. Arquitectura de esta práctica

```text
PostgreSQL farmacia_dw.marts -> Power BI -> Modelo semántico
```

En esta etapa:

- PostgreSQL conserva el modelo físico
- Power BI construye el modelo semántico
- las medidas se definirán en DAX en la siguiente práctica

### 4.1 Qué significa modelo semántico

Un modelo semántico es la capa que traduce las tablas físicas de la base de datos a un lenguaje comprensible para el análisis de negocio.

En PostgreSQL, el DataMart existe como tablas, columnas y claves:

```text
marts.fact_ventas
marts.dim_cliente
marts.dim_producto
marts.dim_fecha
```

En Power BI, el modelo semántico organiza esas tablas para que el usuario pueda analizar sin pensar en joins ni claves técnicas.

El modelo semántico define:

- qué tabla es el hecho principal
- qué tablas son dimensiones
- cómo se relaciónan las dimensiones con el hecho
- qué campos son visibles para el usuario final
- qué campos técnicos deben ocultarse
- qué formato debe tener cada campo numérico
- qué jerarquías permiten navegar el análisis
- qué medidas representarán los indicadores de negocio

En esta práctica se construye la primera parte del modelo semántico:

- tablas
- relaciones
- campos visibles y ocultos
- formatos básicos de campos numéricos
- jerarquías

Las medidas de negocio se construyen en la siguiente práctica.

## 5. Conexión desde Power BI

En Power BI Desktop:

1. Selecciona `Obtener datos`.
2. Elige `Base de datos PostgreSQL`.
3. Usa los datos de conexión del laboratorio:

```text
Servidor: 127.0.0.1:15432
Base de datos: farmacia_dw
```

Credenciales del contenedor:

```text
Usuario: postgres
Password: postgres
```

Importante:

- si Power BI está instalado en Windows y PostgreSQL corre en Docker, usa `127.0.0.1:15432`
- si `localhost:15432` falla con errores de lectura, usa `127.0.0.1:15432`
- si Power BI corre dentro de otro entorno, revisa el host publicado por Docker
- selecciona modo `Importar` para esta primera versión didáctica
- si el DataMart cambia, puedes recargar los datos con `Inicio -> Actualizar`

Nota:

- `Importar` copia los datos dentro del modelo de Power BI
- `DirectQuery` consulta PostgreSQL en vivo cada vez que interactúas con el reporte
- en este laboratorio se recomienda `Importar` porque el modelo queda más rápido y estable para clase

## 6. Selección de tablas

En el navegador de Power BI, selecciona solo las tablas del schema `marts`:

- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_fecha`
- `dim_estado_pedido`
- `fact_ventas`

No importes en esta práctica:

- tablas de `raw`
- vistas de `staging`
- tablas internas de Airbyte

En la ventana `Navegador`:

1. Marca solo las seis tablas de `marts`.
2. Revisa que la vista previa muestre datos.
3. Haz clic en `Cargar`.

No uses `Seleccionar tablas relacionadas`, porque puede traer objetos de otros schemas y ensuciar el modelo semántico.

## 7. Modelo estrella esperado

La tabla central es:

- `fact_ventas`

Dimensiones:

- `dim_fecha`
- `dim_cliente`
- `dim_vendedor`
- `dim_producto`
- `dim_estado_pedido`

Relaciones esperadas:

```text
dim_fecha[fecha_key]                 1 -> * fact_ventas[fecha_key]
dim_cliente[cliente_key]             1 -> * fact_ventas[cliente_key]
dim_vendedor[vendedor_key]           1 -> * fact_ventas[vendedor_key]
dim_producto[producto_key]           1 -> * fact_ventas[producto_key]
dim_estado_pedido[estado_pedido_key] 1 -> * fact_ventas[estado_pedido_key]
```

Configuración recomendada:

- cardinalidad: uno a varios
- dirección de filtro cruzado: simple
- tabla del lado uno: dimensión
- tabla del lado varios: hecho

## 8. Desarrollo en Power BI

### 8.1 Abrir la vista de modelo

Cuando las tablas terminen de cargar:

1. Ve al panel izquierdo.
2. Selecciona la vista `Modelo`.
3. Ubica la tabla `marts fact_ventas` al centro.
4. Coloca las dimensiones alrededor:
   - `marts dim_fecha`
   - `marts dim_cliente`
   - `marts dim_vendedor`
   - `marts dim_producto`
   - `marts dim_estado_pedido`

La idea visual es que el modelo quede como estrella:

```text
dim_fecha          dim_cliente
       \          /
        fact_ventas
       /    |     \
dim_producto dim_vendedor dim_estado_pedido
```

### 8.2 Revisar relaciones automáticas

Power BI puede detectar algunas relaciones automáticamente.

Para revisar una relación:

1. En la vista `Modelo`, haz doble clic sobre la línea de relación.
2. Verifica la tabla de origen y destino.
3. Verifica la cardinalidad.
4. Verifica la dirección de filtro.
5. Confirma que la relación esté activa.

Relación correcta:

```text
Dimensión[clave] 1 -> * fact_ventas[clave]
```

Configuración correcta:

```text
Cardinalidad: Uno a varios
Dirección de filtro cruzado: Simple
Relación activa: Sí
```

### 8.3 Crear relaciones manualmente si faltan

Si una relación no aparece, créala manualmente.

Forma visual:

1. Arrastra la clave desde la dimensión.
2. Sueltala sobre la clave equivalente en `marts fact_ventas`.
3. En la ventana de relación, configura `Uno a varios`.
4. Deja la dirección de filtro en `Simple`.
5. Activa la relación.
6. Haz clic en `Aceptar`.

Relaciones que deben existir:

```text
marts dim_fecha[fecha_key]                 -> marts fact_ventas[fecha_key]
marts dim_cliente[cliente_key]             -> marts fact_ventas[cliente_key]
marts dim_vendedor[vendedor_key]           -> marts fact_ventas[vendedor_key]
marts dim_producto[producto_key]           -> marts fact_ventas[producto_key]
marts dim_estado_pedido[estado_pedido_key] -> marts fact_ventas[estado_pedido_key]
```

Forma por menú:

1. Ve a `Inicio`.
2. Selecciona `Administrar relaciones`.
3. Haz clic en `Nuevo`.
4. Selecciona la dimensión y la tabla `marts fact_ventas`.
5. Elige las columnas clave.
6. Configura cardinalidad `Uno a varios`.
7. Configura dirección de filtro `Simple`.
8. Guarda la relación.

### 8.4 Identificar el grano de `fact_ventas`

En la vista `Datos`, abre:

- `marts fact_ventas`

Observa que:

- `pedido_id` puede repetirse
- `producto_id` puede repetirse
- la fila representa una línea de pedido por producto

Grano oficial:

```text
una fila por línea de pedido por producto
```

Este punto es importante porque define cómo deben interpretarse conteos, sumás y medidas.

### 8.5 Ocultar columnas técnicas

En la vista `Modelo` o en el panel `Datos`:

1. Ubica la tabla `marts fact_ventas`.
2. Haz clic derecho sobre cada clave técnica.
3. Selecciona `Ocultar en la vista de informes`.

Oculta:

- `fecha_key`
- `cliente_key`
- `vendedor_key`
- `producto_key`
- `estado_pedido_key`

También puedes ocultar claves técnicas de las dimensiones cuando no aporten al análisis:

- `cliente_key`
- `vendedor_key`
- `producto_key`
- `estado_pedido_key`
- `cliente_id`
- `vendedor_id`
- `producto_id`
- `categoria_id`
- `familia_id`

Importante:

- ocultar no elimina la columna
- las relaciones siguen funcionando
- solo se limpia el panel de campos para el usuario final
- los campos descriptivos, como `nombre_familia`, `nombre_categoria` y `nombre_producto`, deben quedar visibles

### 8.6 Dejar visibles los campos descriptivos

Verifica que estos campos sigan visibles en el panel `Datos`:

- `marts dim_cliente[nombre_cliente]`
- `marts dim_vendedor[nombre_vendedor]`
- `marts dim_producto[nombre_producto]`
- `marts dim_producto[nombre_categoria]`
- `marts dim_producto[nombre_familia]`
- `marts dim_fecha[fecha]`
- `marts dim_estado_pedido[estado_pedido]`

Estos campos serán los ejes principales de análisis.

### 8.7 Ajustar formatos básicos

En la vista `Datos`:

1. Selecciona una columna numérica.
2. Usa `Herramientas de columnas`.
3. Ajusta el formato según corresponda.

Formato moneda:

- `venta_bruta`
- `descuento_total`
- `venta_neta`
- `costo_total`
- `margen_bruto`

Formato porcentaje:

- `pct_margen_bruto`

Formato número entero:

- `cantidad_vendida`
- `pedido_count`

Resumen predeterminado:

- en campos descriptivos numéricos, usa `No resumir`
- en medidas físicas aditivas, deja `Suma` si corresponde

Configura como `No resumir`:

- `dim_fecha[anio]`
- `dim_fecha[trimestre]`
- `dim_fecha[mes_numero]`
- `dim_fecha[dia]`
- `dim_fecha[dia_semana_numero]`
- claves técnicas como `fecha_key`, `cliente_key`, `producto_key`, `vendedor_key` y `estado_pedido_key`

Esto evita que Power BI trate un año, un mes o una clave como si fueran medidas sumables.

En esta práctica el formato es solo una preparación semántica. Las medidas oficiales se construyen en la P2.

### 8.8 Revisar jerarquía calendario

Power BI puede crear automáticamente una `Jerarquía de fechas` cuando detecta una columna de tipo fecha.

Esa jerarquía automática sirve para una primera exploración:

```text
fecha
  Año
  Trimestre
  Mes
  Día
```

Para esta práctica, puedes usar esa jerarquía automática si ya aparece debajo de `dim_fecha[fecha]`.

Sin embargo, para mantener el curso consistente, desde esta sesión trabajaremos con una jerarquía propia llamada `Calendario`.

Conveniencia didáctica:

- la jerarquía automática sirve para exploración rápida
- la jerarquía propia permite gobernar nombres, ordenamientos y campos
- en adelante usaremos la jerarquía propia `Calendario`

En el panel `Datos`:

1. Abre la tabla `marts dim_fecha`.
2. Haz clic derecho sobre `anio`.
3. Selecciona `Crear jerarquía`.
4. Renombra la jerarquía como `Calendario`.
5. Arrastra dentro de la jerarquía:
   - `trimestre`
   - `mes_desc`
   - `fecha`

La jerarquía debe quedar así:

```text
Calendario
  anio
  trimestre
  mes_desc
  fecha
```

Nota:

- no uses la jerarquía automática de Power BI como jerarquía oficial del curso
- usa `Calendario` para las prácticas posteriores
- `anio`, `trimestre`, `mes_numero` y `dia` deben quedar como `No resumir`

Nota sobre inteligencia de tiempo:

- Power BI puede crear calendarios automáticos y funciones de inteligencia de tiempo
- ese enfoque suele generar una tabla calendario desde la fecha mínima hasta la fecha máxima detectada
- en este curso no usaremos esa ruta como enfoque principal
- trabajaremos con la dimensión `marts dim_fecha` construida desde el DataMart
- si se revisan videos externos sobre inteligencia de tiempo, tómalos como referencia conceptual, no como la ruta operativa de esta práctica

### 8.9 Crear jerarquía comercial de producto

En el panel `Datos`:

1. Abre la tabla `marts dim_producto`.
2. Haz clic derecho sobre `nombre_familia`.
3. Selecciona `Crear jerarquía`.
4. Renombra la jerarquía como `Producto Comercial`.
5. Arrastra dentro de la jerarquía:
   - `nombre_categoria`
   - `nombre_producto`

La jerarquía debe quedar así:

```text
Producto Comercial
  nombre_familia
  nombre_categoria
  nombre_producto
```

### 8.10 Validar el modelo con una tabla temporal

Vuelve a la vista `Informe`.

1. Inserta un visual de tipo `Tabla`.
2. Agrega `marts dim_producto[nombre_producto]`.
3. Agrega `marts fact_ventas[venta_neta]`.
4. Verifica que `venta_neta` se agregue como suma.

Resultado esperado:

- Power BI muestra ventas agrupadas por producto
- no necesitas hacer joins en Power Query
- las relaciones del modelo hacen el cruce entre dimensión y hecho

Este visual es solo de validación. El diseño formal de reportes empieza en la sesión 4.

## 9. Resultado esperado del modelo semántico

Al cerrar esta práctica, el archivo de Power BI debe contener un modelo semántico base con las siguientes características.

### 9.1 Tablas cargadas

Solo deben estar cargadas las tablas analíticas del schema `marts`:

- `marts dim_cliente`
- `marts dim_vendedor`
- `marts dim_producto`
- `marts dim_fecha`
- `marts dim_estado_pedido`
- `marts fact_ventas`

No deben formar parte del modelo:

- tablas de `raw`
- vistas de `staging`
- tablas internas de Airbyte

### 9.2 Estructura del modelo

El modelo debe verse como una estrella:

- tabla central: `marts fact_ventas`
- dimensiones alrededor:
  - `marts dim_fecha`
  - `marts dim_cliente`
  - `marts dim_vendedor`
  - `marts dim_producto`
  - `marts dim_estado_pedido`

### 9.3 Relaciones esperadas

Todas las relaciones deben ser de uno a muchos:

```text
marts dim_fecha[fecha_key]                 1 -> * marts fact_ventas[fecha_key]
marts dim_cliente[cliente_key]             1 -> * marts fact_ventas[cliente_key]
marts dim_vendedor[vendedor_key]           1 -> * marts fact_ventas[vendedor_key]
marts dim_producto[producto_key]           1 -> * marts fact_ventas[producto_key]
marts dim_estado_pedido[estado_pedido_key] 1 -> * marts fact_ventas[estado_pedido_key]
```

Configuración esperada:

- cardinalidad: `Uno a varios`
- dirección de filtro cruzado: `Simple`
- tabla del lado uno: dimensión
- tabla del lado varios: hecho
- relación activa

### 9.4 Campos técnicos ocultos

Las claves usadas para relaciones deben permanecer en el modelo, pero ocultas para el usuario final:

- `marts fact_ventas[fecha_key]`
- `marts fact_ventas[cliente_key]`
- `marts fact_ventas[vendedor_key]`
- `marts fact_ventas[producto_key]`
- `marts fact_ventas[estado_pedido_key]`

También pueden ocultarse claves de dimensiones si no aportan al análisis visual:

- `cliente_key`
- `vendedor_key`
- `producto_key`
- `estado_pedido_key`
- `cliente_id`
- `vendedor_id`
- `producto_id`
- `categoria_id`
- `familia_id`

### 9.5 Campos descriptivos visibles

El usuario final debe poder analizar usando campos descriptivos:

- `marts dim_cliente[nombre_cliente]`
- `marts dim_vendedor[nombre_vendedor]`
- `marts dim_producto[nombre_producto]`
- `marts dim_producto[nombre_categoria]`
- `marts dim_producto[nombre_familia]`
- `marts dim_fecha[fecha]`
- `marts dim_estado_pedido[estado_pedido]`

Los campos numéricos usados como atributos, por ejemplo `anio`, `trimestre`, `mes_numero` o `dia`, deben quedar con resumen predeterminado `No resumir`.

### 9.6 Jerarquías disponibles

Debe existir una jerarquía calendario disponible.

La jerarquía oficial del curso será la jerarquía propia creada sobre `dim_fecha`:

```text
Calendario
  anio
  trimestre
  mes_desc
  fecha
```

No se usará la jerarquía automática de Power BI como jerarquía principal del modelo.

Sí debe existir una jerarquía comercial de producto:

```text
Producto Comercial
  nombre_familia
  nombre_categoria
  nombre_producto
```

### 9.7 Validación mínima

El modelo debe permitir crear una tabla visual temporal con:

- `marts dim_producto[nombre_producto]`
- suma de `marts fact_ventas[venta_neta]`

Resultado esperado:

- Power BI agrupa ventas por producto
- los filtros desde dimensiones afectan al hecho
- no es necesario hacer joins manuales en Power Query

No se espera todavía:

- crear medidas DAX finales
- diseñar un dashboard
- trabajar drill-through o tooltips
- profundizar en ordenamiento avanzado de columnas

## 10. Evidencias a entregar

- captura de la conexión a PostgreSQL
- captura de las seis tablas importadas desde `marts`
- captura de la vista de modelo con relaciones
- captura de la jerarquía calendario
- captura de la jerarquía comercial de producto
- captura de una tabla visual con ventas por producto

## 11. Cierre

Con esta práctica, el DataMart físico queda convertido en un modelo semántico navegable. La siguiente práctica agrega las medidas DAX para que el análisis use métricas gobernadas y no agregaciones improvisadas en cada visual.
