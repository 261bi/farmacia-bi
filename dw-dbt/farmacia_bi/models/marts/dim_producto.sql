select
    producto_id as producto_key,
    producto_id,
    codigo_producto,
    nombre_producto,
    precio_compra as precio_compra_referencia,
    precio_venta as precio_venta_referencia,
    categoria_id,
    nombre_categoria,
    familia_id,
    nombre_familia
from {{ ref('stg_productos') }}
