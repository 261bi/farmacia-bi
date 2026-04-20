select
    vendedor_id as vendedor_key,
    vendedor_id,
    nombre_vendedor
from {{ ref('stg_vendedores') }}
