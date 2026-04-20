select distinct
    dense_rank() over (order by estado_pedido) as estado_pedido_key,
    estado_pedido
from {{ ref('stg_pedidos') }}
where estado_pedido is not null
