with productos as (
    select
        id as producto_id,
        codigo as codigo_producto,
        nombre as nombre_producto_base,
        concentracion,
        presentacion,
        fracciones,
        precio_compra,
        precio_venta,
        categoria_id
    from raw.productos
),
categorias as (
    select
        id as categoria_id,
        nombre as nombre_categoria,
        familia_id
    from raw.categorias
),
familias as (
    select
        familia_id,
        nombre_familia
    from {{ ref('stg_familias') }}
)

select
    p.producto_id,
    p.codigo_producto,
    trim(
        regexp_replace(
            concat(
                p.nombre_producto_base,
                ' ',
                coalesce(nullif(p.concentracion, ''), ''),
                ' ',
                coalesce(nullif(p.presentacion, ''), ''),
                ' frac',
                coalesce(nullif(p.fracciones, ''), '')
            ),
            '\s+',
            ' ',
            'g'
        )
    ) as nombre_producto,
    p.precio_compra,
    p.precio_venta,
    c.categoria_id,
    c.nombre_categoria,
    f.familia_id,
    f.nombre_familia
from productos p
inner join categorias c
    on p.categoria_id = c.categoria_id
inner join familias f
    on c.familia_id = f.familia_id
