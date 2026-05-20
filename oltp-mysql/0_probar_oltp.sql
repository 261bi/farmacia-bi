

select  sum(cantidad* precio_venta_unitario)
from pedido_detalles

select  (sum(cantidad* precio_venta_unitario) - sum(cantidad* total_descuento_unitario))
from pedido_detalles

select  sum(cantidad* total_descuento_unitario)
from pedido_detalles