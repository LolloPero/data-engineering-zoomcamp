with dim_fhv_trip as (

  SELECT *,
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration
  FROM {{ ref('dim_fhv_trips') }}
),

dim_fhv_trip_p90 as (
SELECT 
    year,
    month,
    pulocationid,
    pickup_borough,
    pickup_zone,
    dolocationid,
    dropoff_borough,
    dropoff_zone,
    PERCENTILE_CONT(trip_duration, 0.90) 
        OVER (PARTITION BY year, month, pulocationid, dolocationid) AS p90_trip_duration
FROM dim_fhv_trip
)

select DISTINCT *
FROM dim_fhv_trip_p90
ORDER BY pickup_zone, p90_trip_duration DESC