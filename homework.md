## Week 4 Homework 

In this homework, we'll use the models developed during the week 4 videos and enhance the already presented dbt project using the already loaded Taxi data for fhv vehicles for year 2019 in our DWH.

This means that in this homework we use the following data [Datasets list](https://github.com/DataTalksClub/nyc-tlc-data/)
* Yellow taxi data - Years 2019 and 2020
* Green taxi data - Years 2019 and 2020 
* fhv data - Year 2019. 

We will use the data loaded for:

* Building a source table: `stg_fhv_tripdata`
* Building a fact table: `fact_fhv_trips`
* Create a dashboard 

If you don't have access to GCP, you can do this locally using the ingested data from your Postgres database
instead. If you have access to GCP, you don't need to do it for local Postgres -
only if you want to.

> **Note**: if your answer doesn't match exactly, select the closest option 

### Question 1: 

**What is the count of records in the model fact_trips after running all models with the test run variable disabled and filtering for 2019 and 2020 data only (pickup datetime)?** 

You'll need to have completed the ["Build the first dbt models"](https://www.youtube.com/watch?v=UVI30Vxzd6c) video and have been able to run the models via the CLI. 
You should find the views and models for querying in your DWH.

- 41648442
- 51648442
- 61648442
- 71648442

>Code:
```sql
SELECT COUNT(*) FROM `lucid-volt-375207.production.fact_trips`
WHERE EXTRACT(YEAR FROM pickup_datetime) IN  (2019, 2020) 
```
>Answer (incorrect):
```
Code output:
61604283

Chosen answer:
61648442
```


### Question 2: 

**What is the distribution between service type filtering by years 2019 and 2020 data as done in the videos?**

You will need to complete "Visualising the data" videos, either using [google data studio](https://www.youtube.com/watch?v=39nLTs74A3E) or [metabase](https://www.youtube.com/watch?v=BnLkrA7a6gM). 

- 89.9/10.1
- 94/6
- 76.3/23.7
- 99.1/0.9

>Code:

![distribution](h4_w1_pie_chart.png)

>Answer (correct):
```
Chart Output
89.8/10.2

Chosen answer:
89.9/10.1
```


### Question 3: 

**What is the count of records in the model stg_fhv_tripdata after running all models with the test run variable disabled (:false)?**  

Create a staging model for the fhv data for 2019 and do not add a deduplication step. Run it via the CLI without limits (is_test_run: false).
Filter records with pickup time in year 2019.

- 33244696
- 43244696
- 53244696
- 63244696

>Code 1: [stg_fhv_tripdata.sql](ny_taxi_rides/models/staging/stg_fhv_tripdata.sql)

>Code 2:
```sql
SELECT count(*) FROM `lucid-volt-375207.production.stg_fhv_tripdata`
where extract(year from pickup_datetime) in (2019)
```
>Answer:
```
43244693
```
> Proposed code 1 - `stg_fhv_tripdata.sql`
```sql
{{ config(materialized='view') }}

select
    -- identifiers
    {{ dbt_utils.surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    cast(dispatching_base_num as string) as vendorid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    sr_flag

from {{ source('staging','fhv_tripdata_external') }}
where dispatching_base_num is not null 
```
> Proposed code 2
```sql
SELECT count(*) FROM `lucid-volt-375207.production.stg_fhv_tripdata`
where extract(year from pickup_datetime) in (2019)
```

### Question 4: 

**What is the count of records in the model fact_fhv_trips after running all dependencies with the test run variable disabled (:false)?**  

Create a core model for the stg_fhv_tripdata joining with dim_zones.
Similar to what we've done in fact_trips, keep only records with known pickup and dropoff locations entries for pickup and dropoff locations. 
Run it via the CLI without limits (is_test_run: false) and filter records with pickup time in year 2019.

- 12998722
- 22998722
- 32998722
- 42998722


>Code 1: [fact_fhv_trips.sql](ny_taxi_rides/models/core/fact_fhv_trips.sql)

>Code 2:
```sql
SELECT count(*) FROM `lucid-volt-375207.production.fact_fhv_trips`
where extract(year from pickup_datetime) in (2019)
```

>Answer:
```
22998722
```

>Proposed code 1 - `stg_fhv_trips.sql`
```sql
{{ config(materialized='view')}}

with fhv_data as(
    select *,
        'Fhv' as service_type
    from {{ ref('stg_fhv_tripdata') }}
)

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select
    fhv_data.dispatching_base_num,
    fhv_dat.service_type,
    fhv_data.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    fhv_data.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    fhv_data.pickup_datetime,
    fhv_data.dropoff_datetime,
    fhv_data.sr_flag
from fhv_data
inner join dim_zones as pickup_zone
on fhv_data.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_data.dropoff_locationid = dropoff_zone.locationid
```

>Proposed code 2
```sql
SELECT count(*) FROM `lucid-volt-375207.production.fact_fhv_trips`
where extract(year from pickup_datetime) in (2019)
```

### Question 5: 

**What is the month with the biggest amount of rides after building a tile for the fact_fhv_trips table?**

Create a dashboard with some tiles that you find interesting to explore the data. One tile should show the amount of trips per month, as done in the videos for fact_trips, based on the fact_fhv_trips table.

- March
- April
- January
- December


>Code: [report](https://lookerstudio.google.com/reporting/1e05e8bf-bbc8-48b3-9c1c-be3263d4ac4b)

>Answer (correct):
```
January
```



## Submitting the solutions

* Form for submitting: https://forms.gle/6A94GPutZJTuT5Y16
* You can submit your homework multiple times. In this case, only the last submission will be used. 

Deadline: 25 February (Saturday), 22:00 CET


## Solution

We will publish the solution here
