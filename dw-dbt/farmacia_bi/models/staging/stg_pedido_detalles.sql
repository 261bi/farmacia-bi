select
    pedido_id,
    producto_id,
    cantidad,
    precio_compra_unitario,
    precio_venta_unitario,
    total_descuento_unitario,
    igv_unitario
from raw.pedido_detalles
