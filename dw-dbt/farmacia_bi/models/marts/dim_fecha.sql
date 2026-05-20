with fechas as (
    select distinct
        fecha_creacion::date as fecha
    from {{ ref('stg_pedidos') }}
    where fecha_creacion is not null
)

select
    cast(to_char(fecha, 'YYYYMMDD') as bigint) as fecha_key,
    fecha,
    extract(day from fecha)::int as dia,
    (extract(dow from fecha)::int + 1) as dia_semana_numero,
    case extract(dow from fecha)::int
        when 0 then 'domingo'
        when 1 then 'lunes'
        when 2 then 'martes'
        when 3 then 'miércoles'
        when 4 then 'jueves'
        when 5 then 'viernes'
        when 6 then 'sábado'
    end as dia_semana_desc,
    extract(month from fecha)::int as mes_numero,
    case extract(month from fecha)::int
        when 1 then 'enero'
        when 2 then 'febrero'
        when 3 then 'marzo'
        when 4 then 'abril'
        when 5 then 'mayo'
        when 6 then 'junio'
        when 7 then 'julio'
        when 8 then 'agosto'
        when 9 then 'septiembre'
        when 10 then 'octubre'
        when 11 then 'noviembre'
        when 12 then 'diciembre'
    end as mes_desc,
    extract(quarter from fecha)::int as trimestre,
    extract(year from fecha)::int as anio
from fechas
