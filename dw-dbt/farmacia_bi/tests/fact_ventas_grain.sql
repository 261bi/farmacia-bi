select
    pedido_id,
    producto_id,
    count(*) as repeticiones
from {{ ref('fact_ventas') }}
group by pedido_id, producto_id
having count(*) > 1
