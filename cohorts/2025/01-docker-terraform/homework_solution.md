# Module 1 Homework: Docker & SQL


## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.

What's the version of `pip` in the image?

- 24.3.1
- 24.2.1
- 23.3.1
- 23.2.1

*Solution:*

```
lorper@Lorenzos-Laptop data-engineering-zoomcamp % docker run -it --entrypoint bash python:3.12.8
root@41be242dc414:/# pip --version
pip 24.3.1 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)
```


## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- postgres:5432
- db:5432

If there are more than one answers, select only one of them


*Solution:*
postgres:5432

```
docker-compose up
```
Connect to localhost:8080

Setup pgadmin to connect to hostname=postgres and port=5432.
pgadmin runs within the same network as postgres container, hence it should access the container internal port(5432).

##  Prepare Postgres

Run Postgres and load data as shown in the videos
We'll use the green taxi trips from October 2019:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
```

You will also need the dataset with zones:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

Download this data and put it into Postgres.

You can use the code from the course. It's up to you whether
you want to use Jupyter or a python script.

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

Answers:

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
- 104,838;  199,013;  109,645;  27,688;  35,202


*Solution:*
Sequennce is: 104802; 198924; 109603; 27678; 35189
1. Up to 1 mile
```
SELECT count(*)
FROM public.green_taxi_data
WHERE 	lpep_pickup_datetime >= '2019-10-01' AND
		    lpep_dropoff_datetime < '2019-11-01' AND
		    trip_distance <= 1
---------
"count"
104802
```
2. In between 1 (exclusive) and 3 miles (inclusive),
```
SELECT count(*)
FROM public.green_taxi_data
WHERE 	lpep_pickup_datetime >= '2019-10-01' AND
		    lpep_dropoff_datetime < '2019-11-01' AND
		    trip_distance >  1 AND
        trip_distance <= 3
---------
"count"
198924
```
3. In between 3 (exclusive) and 7 miles (inclusive),
```
SELECT count(*)
FROM public.green_taxi_data
WHERE 	lpep_pickup_datetime >= '2019-10-01' AND
		    lpep_dropoff_datetime < '2019-11-01' AND
		    trip_distance >  3 AND
        trip_distance <= 7
---------
"count"
109603
```
4. In between 7 (exclusive) and 10 miles (inclusive),
```
SELECT count(*)
FROM public.green_taxi_data
WHERE 	lpep_pickup_datetime >= '2019-10-01' AND
		    lpep_dropoff_datetime < '2019-11-01' AND
		    trip_distance <= 1
---------
"count"
27678
```
5. Over 10 miles 
```
SELECT count(*)
FROM public.green_taxi_data
WHERE 	lpep_pickup_datetime >= '2019-10-01' AND
		    lpep_dropoff_datetime < '2019-11-01' AND
		    trip_distance > 10
---------
"count"
35189
```



## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance. 

- 2019-10-11
- 2019-10-24
- 2019-10-26
- 2019-10-31

*Solution:*
```
SELECT 	lpep_pickup_datetime,
		    trip_distance
FROM public.green_taxi_data
ORDER BY trip_distance DESC
```
"lpep_pickup_datetime"	"trip_distance"
"2019-10-31 23:23:41"	   515.89

## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.
 
- East Harlem North, East Harlem South, Morningside Heights
- East Harlem North, Morningside Heights
- Morningside Heights, Astoria Park, East Harlem South
- Bedford, East Harlem North, Astoria Park


*Solution:*
```
SELECT 	CAST(gtd.lpep_pickup_datetime AS DATE) pickup_date,
		ROUND(CAST(SUM(gtd.total_amount) AS BIGINT),1) total_amount,
		z."Zone"
FROM 
	public.green_taxi_data gtd
	JOIN 
	public.zones z
	ON gtd."PULocationID" = z."LocationID"
GROUP BY
	pickup_date,"Zone"
HAVING ROUND(CAST(SUM(gtd.total_amount) AS BIGINT),1) > 13000 AND
		CAST(gtd.lpep_pickup_datetime AS DATE) = '2019-10-18'
ORDER BY pickup_date, total_amount DESC

-----------------
"pickup_date"	"total_amount"	"Zone"
"2019-10-18"	18687.0	"East Harle m North"
"2019-10-18"	16797.0	"East Harlem South"
"2019-10-18"	13030.0	"Morningside Heights"

```



## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
named "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

- Yorkville West
- JFK Airport
- East Harlem North
- East Harlem South


*Solution:*
```
SELECT 	TO_CHAR(t.lpep_pickup_datetime, 'YYYY-MM') pickup_month,
		t.tip_amount,
		zpu."Zone" pickup_zone,
		zdo."Zone" dropoff_zone
FROM 
	public.green_taxi_data t,
	public.zones zpu,
	public.zones zdo
WHERE
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID" AND
	TO_CHAR(t.lpep_pickup_datetime, 'YYYY-MM') = '2019-10' AND
	zpu."Zone" = 'East Harlem North'
ORDER BY
	tip_amount DESC

--------
"pickup_month"	"tip_amount"	"pickup_zone"	"dropoff_zone"
"2019-10"	87.3	"East Harlem North"	"JFK Airport"

```

## Terraform

In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. 
Copy the files from the course repo
[here](../../../01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.


## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 
1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:
- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm

*Solution:*
 - `terraform init` (download provider plugins)
 - `terraform apply -auto-approve` (Generates proposed changes)
 - `terraform destroy` (Removes all resources)

## Submitting the solutions

* Form for submitting: https://courses.datatalks.club/de-zoomcamp-2025/homework/hw1
