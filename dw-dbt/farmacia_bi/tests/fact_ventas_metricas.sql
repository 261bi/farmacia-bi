select *
from {{ ref('fact_ventas') }}
where venta_neta <> venta_bruta - descuento_total
   or margen_bruto <> venta_neta - costo_total
   or cantidad_vendida < 0
   or venta_bruta < 0
   or descuento_total < 0
   or venta_neta < 0
   or costo_total < 0
