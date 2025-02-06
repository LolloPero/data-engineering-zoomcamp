-- Create external table from .parquet files
CREATE OR REPLACE EXTERNAL TABLE `banded-lexicon-449417-v6.zoomcamp.external_yellow_tripdata_01to06_2024`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://kestra-de-zoomcap-bucket/yellow_tripdata_2024-*.parquet']
);

-- Create a (regular) table from external table
CREATE OR REPLACE TABLE `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024` AS
SELECT * FROM `banded-lexicon-449417-v6.zoomcamp.external_yellow_tripdata_01to06_2024`;


-- Question 1:
SELECT count(1)
FROM `banded-lexicon-449417-v6.zoomcamp.external_yellow_tripdata_01to06_2024`;

-- Question 2: 
SELECT DISTINCT(PULocationID)
FROM `banded-lexicon-449417-v6.zoomcamp.external_yellow_tripdata_01to06_2024`;

SELECT DISTINCT(PULocationID)
FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024`;

-- Question 4:
SELECT count(1)
FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024`
WHERE fare_amount = 0;

-- Question 5:
CREATE OR REPLACE TABLE `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024`;


-- Question 6:
SELECT DISTINCT(VendorID)
FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024`
WHERE tpep_dropoff_datetime > '2024-03-01' AND
      tpep_dropoff_datetime <= '2024-03-15';

SELECT DISTINCT(VendorID)
FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024_partitioned_clustered`
WHERE tpep_dropoff_datetime > '2024-03-01' AND
      tpep_dropoff_datetime <= '2024-03-15';

-- Question 9;
SELECT *
FROM `banded-lexicon-449417-v6.zoomcamp.yellow_tripdata_01to06_2024`;
