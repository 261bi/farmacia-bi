with pedidos as (
    select
        pedido_id,
        fecha_creacion,
        fecha_confirmacion,
        fecha_envio,
        fecha_entrega,
        estado_pedido,
        cliente_id,
        vendedor_id
    from {{ ref('stg_pedidos') }}
),
pedido_detalles as (
    select
        pedido_id,
        producto_id,
        cantidad,
        precio_compra_unitario,
        precio_venta_unitario,
        total_descuento_unitario,
        igv_unitario
    from {{ ref('stg_pedido_detalles') }}
),
dim_fecha as (
    select
        fecha_key,
        fecha
    from {{ ref('dim_fecha') }}
),
dim_cliente as (
    select
        cliente_key,
        cliente_id
    from {{ ref('dim_cliente') }}
),
dim_vendedor as (
    select
        vendedor_key,
        vendedor_id
    from {{ ref('dim_vendedor') }}
),
dim_producto as (
    select
        producto_key,
        producto_id
    from {{ ref('dim_producto') }}
),
dim_estado_pedido as (
    select
        estado_pedido_key,
        estado_pedido
    from {{ ref('dim_estado_pedido') }}
)

select
    df.fecha_key,
    dc.cliente_key,
    dv.vendedor_key,
    dp.producto_key,
    dep.estado_pedido_key,
    p.pedido_id,
    pd.producto_id,
    pd.cantidad as cantidad_vendida,
    pd.cantidad * pd.precio_venta_unitario as venta_bruta,
    pd.cantidad * coalesce(pd.total_descuento_unitario, 0) as descuento_total,
    (pd.cantidad * pd.precio_venta_unitario) - (pd.cantidad * coalesce(pd.total_descuento_unitario, 0)) as venta_neta,
    pd.cantidad * coalesce(pd.precio_compra_unitario, 0) as costo_total,
    ((pd.cantidad * pd.precio_venta_unitario) - (pd.cantidad * coalesce(pd.total_descuento_unitario, 0)))
        - (pd.cantidad * coalesce(pd.precio_compra_unitario, 0)) as margen_bruto,
    case
        when ((pd.cantidad * pd.precio_venta_unitario) - (pd.cantidad * coalesce(pd.total_descuento_unitario, 0))) = 0 then null
        else
            (
                (
                    ((pd.cantidad * pd.precio_venta_unitario) - (pd.cantidad * coalesce(pd.total_descuento_unitario, 0)))
                    - (pd.cantidad * coalesce(pd.precio_compra_unitario, 0))
                )
                /
                ((pd.cantidad * pd.precio_venta_unitario) - (pd.cantidad * coalesce(pd.total_descuento_unitario, 0)))
            )
    end as pct_margen_bruto,
    case
        when p.fecha_confirmacion is not null then
            extract(epoch from (p.fecha_confirmacion - p.fecha_creacion)) / 60.0
        else null
    end as minutos_confirmacion,
    case
        when p.fecha_confirmacion is not null and p.fecha_envio is not null then
            extract(epoch from (p.fecha_envio - p.fecha_confirmacion)) / 60.0
        else null
    end as minutos_despacho,
    case
        when p.fecha_envio is not null and p.fecha_entrega is not null then
            extract(epoch from (p.fecha_entrega - p.fecha_envio)) / 3600.0
        else null
    end as horas_entrega,
    case
        when p.fecha_entrega is not null then
            extract(epoch from (p.fecha_entrega - p.fecha_creacion)) / 3600.0
        else null
    end as horas_lead_time,
    1 as pedido_count,
    pd.igv_unitario
from pedido_detalles pd
inner join pedidos p
    on pd.pedido_id = p.pedido_id
inner join dim_fecha df
    on p.fecha_creacion::date = df.fecha
inner join dim_cliente dc
    on p.cliente_id = dc.cliente_id
left join dim_vendedor dv
    on p.vendedor_id = dv.vendedor_id
inner join dim_producto dp
    on pd.producto_id = dp.producto_id
inner join dim_estado_pedido dep
    on p.estado_pedido = dep.estado_pedido
