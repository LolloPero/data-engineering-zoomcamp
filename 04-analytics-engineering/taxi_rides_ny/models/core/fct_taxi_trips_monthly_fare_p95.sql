{{
    config(
        materialized='table'
    )
}}


select 
    service_type,
    year,
    month,
    fare_amount,
    floor(
        percent_rank() over (
            partition by service_type, year, month 
            order by fare_amount
        ) * 100 
    ) / 100 as percentile
from {{ ref('dim_taxi_trips') }}
where 
    fare_amount > 0
    and trip_distance > 0
    and payment_type_description in ('Cash', 'Credit Card')
order by service_type, year, month, fare_amount
