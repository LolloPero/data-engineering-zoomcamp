{{
    config(
        materialized='table'
    )
}}

-- quarterly revenue
with quarterly_revenue as (
    select
        service_type,
        year,
        quarter, 
        SUM(total_amount) as quarterly_revenue
    from {{ ref('dim_taxi_trips') }}
    group by service_type, year, quarter
),

-- YoY revenue growth
yoy as (
    select 
        qr_1.service_type,
        qr_1.year,
        qr_1.quarter,
        qr_1.quarterly_revenue,
        qr_2.quarterly_revenue AS prev_year_revenue,
        -- Compute YoY Growth (Avoid division by zero)
        case 
            when qr_2.quarterly_revenue is not null and qr_2.quarterly_revenue <> 0 
            then ((qr_1.quarterly_revenue - qr_2.quarterly_revenue) / qr_2.quarterly_revenue) * 100
            else NULL
        end as yoy_growth_percentage
    from quarterly_revenue qr_1
    left join quarterly_revenue qr_2 
        on qr_1.service_type = qr_2.service_type  -- Ensure we compare within the same service type
        and qr_1.quarter = qr_2.quarter  -- Match the same quarter
        and qr_1.year = qr_2.year + 1  -- Compare with the previous year
)

SELECT * 
FROM yoy
ORDER BY service_type, year, quarter DESC