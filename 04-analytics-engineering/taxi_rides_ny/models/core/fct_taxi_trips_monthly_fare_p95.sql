{{
    config(
        materialized='table'
    )
}}


with percentile_table as (
    select 
        service_type,
        year,
        month,
        fare_amount,
        ROUND(
                percent_rank() over (
                                        partition by service_type, year, month 
                                        order by fare_amount
                                    )
            ,2) as percentile
    from {{ ref('dim_taxi_trips') }}
        where 
        fare_amount > 0
        and trip_distance > 0
        and payment_type_description in ('Cash', 'Credit Card')
)
select  service_type, 
        year, 
        month,  
        percentile, 
        AVG(fare_amount) as fare_amount
from 
        percentile_table
group by 
        service_type, year, month,  percentile
order by 
        service_type, year desc, month,  percentile
