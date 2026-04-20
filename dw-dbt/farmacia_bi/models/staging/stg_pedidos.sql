select
    id as pedido_id,
    fecha_creacion,
    fecha_modificacion,
    fecha_confirmacion,
    fecha_envio,
    fecha_entrega,
    fecha_pago,
    estado as estado_pedido,
    cliente_id,
    direccion,
    vendedor_id
from raw.pedidos
