select
    cliente_id as cliente_key,
    cliente_id,
    nombre_cliente
from {{ ref('stg_clientes') }}
