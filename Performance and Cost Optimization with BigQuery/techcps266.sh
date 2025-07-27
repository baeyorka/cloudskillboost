


gcloud auth list

export GCP_PROJECT_ID=$(gcloud config list core/project --format="value(core.project)")

gcloud storage buckets create gs://${GCP_PROJECT_ID}-cymbal-bq-opt --project=${GCP_PROJECT_ID} --location=EU --uniform-bucket-level-access

gsutil cp gs://spls/gsp266/departments.csv gs://${GCP_PROJECT_ID}-cymbal-bq-opt/departments.csv

gsutil cp gs://spls/gsp266/aisles.csv gs://${GCP_PROJECT_ID}-cymbal-bq-opt/aisles.csv

gsutil cp gs://spls/gsp266/products.csv gs://${GCP_PROJECT_ID}-cymbal-bq-opt/products.csv

gsutil cp gs://spls/gsp266/orders_with_timestamps.csv gs://${GCP_PROJECT_ID}-cymbal-bq-opt/orders_with_timestamps.csv

gsutil cp gs://spls/gsp266/order_products.csv gs://${GCP_PROJECT_ID}-cymbal-bq-opt/order_products.csv


gsutil ls -l gs://${GCP_PROJECT_ID}-cymbal-bq-opt/

bq --location=EU mk \
    --dataset \
    ${GCP_PROJECT_ID}:cymbal_bq_opt_1

bq --location=EU mk \
    --dataset \
    ${GCP_PROJECT_ID}:cymbal_bq_opt_2

bq load \
--autodetect \
--source_format=CSV \
cymbal_bq_opt_1.departments \
gs://${GCP_PROJECT_ID}-cymbal-bq-opt/departments.csv

bq load \
--autodetect \
--source_format=CSV \
cymbal_bq_opt_1.aisles \
gs://${GCP_PROJECT_ID}-cymbal-bq-opt/aisles.csv

bq load \
--autodetect \
--source_format=CSV \
cymbal_bq_opt_1.products \
gs://${GCP_PROJECT_ID}-cymbal-bq-opt/products.csv

bq load \
--autodetect \
--source_format=CSV \
cymbal_bq_opt_1.orders_with_timestamps \
gs://${GCP_PROJECT_ID}-cymbal-bq-opt/orders_with_timestamps.csv

bq load \
--autodetect \
--source_format=CSV \
cymbal_bq_opt_1.order_products \
gs://${GCP_PROJECT_ID}-cymbal-bq-opt/order_products.csv

bq ls cymbal_bq_opt_1





bq query --use_legacy_sql=false \
'
SELECT
 order_ts,
 order_hour_of_day,
 COUNT(order_id)
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
WHERE
 DATE(order_ts) = "2022-08-01"
GROUP BY
 order_ts,
 order_hour_of_day
ORDER BY
 order_hour_of_day ASC;
'


bq query --use_legacy_sql=false \
'
WITH
 target_orders AS (
 SELECT
   order_id
 FROM
   `cymbal_bq_opt_1.orders_with_timestamps`
 WHERE
   DATE(order_ts) = "2022-08-01" )
SELECT
 p.product_name,
 COUNT(*) AS volume_of_product_purchased
FROM
 target_orders o
INNER JOIN
 `cymbal_bq_opt_1.order_products` map
ON
 o.order_id = map.order_id
INNER JOIN
 `cymbal_bq_opt_1.products` p
ON
 map.product_id = p.product_id
GROUP BY
 p.product_name
ORDER BY
 volume_of_product_purchased DESC;'




bq query --use_legacy_sql=false \
'
SELECT
 o.product_id,
 p.product_name
FROM
 `cymbal_bq_opt_1.order_products` o
 JOIN
 `cymbal_bq_opt_1.products` p
 on o.product_id = p.product_id
WHERE
 order_id = 1564244;'


bq query --use_legacy_sql=false \
'
SELECT
 TIMESTAMP_TRUNC(order_ts, HOUR) AS order_hour,
 COUNT(*) AS volume_of_orders
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
GROUP BY
 order_hour
ORDER BY
 order_hour;
'



bq query --use_legacy_sql=false \
'
SELECT
 order_ts,
 order_hour_of_day,
 COUNT(order_id)
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
WHERE
 DATE(order_ts) = "2022-08-01"
GROUP BY
 order_ts,
 order_hour_of_day
ORDER BY
 order_hour_of_day ASC;
'


bq query --use_legacy_sql=false \
'
CREATE TABLE
 cymbal_bq_opt_2.orders_with_timestamps
PARTITION BY
 DATE(order_ts) OPTIONS ( require_partition_filter = TRUE) AS
SELECT
 *
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`;'



bq query --use_legacy_sql=false \
'
SELECT
 order_ts,
 order_hour_of_day,
 COUNT(order_id)
FROM
 `cymbal_bq_opt_2.orders_with_timestamps`
WHERE
 DATE(order_ts) = "2022-08-01"
GROUP BY
 order_ts,
 order_hour_of_day
ORDER BY
 order_hour_of_day ASC;'


bq query --use_legacy_sql=false \
'
WITH
 target_orders AS (
 SELECT
   order_id
 FROM
   `cymbal_bq_opt_1.orders_with_timestamps`
 WHERE
   DATE(order_ts) = "2022-08-01" )
SELECT
 p.product_name,
 COUNT(*) AS volume_of_product_purchased
FROM
 target_orders o
INNER JOIN
 `cymbal_bq_opt_1.order_products` map
ON
 o.order_id = map.order_id
INNER JOIN
 `cymbal_bq_opt_1.products` p
ON
 map.product_id = p.product_id
GROUP BY
 p.product_name
ORDER BY
 volume_of_product_purchased DESC;'




bq query --use_legacy_sql=false \
'
CREATE TABLE
cymbal_bq_opt_2.orders_nested
PARTITION BY
 DATE(order_ts) OPTIONS ( require_partition_filter = TRUE) AS
WITH
 flat_orders AS (
 SELECT
   o.order_id,
   o.order_ts,
   o.order_dow,
   o.order_hour_of_day,
   o.user_id,
   o.days_since_prior_order,
   o.order_number,
   STRUCT( p.product_id,
     p.product_name,
     p.aisle_id,
     p.department_id,
     map.add_to_cart_order,
     map.reordered ) AS product_purchased
 FROM
   `cymbal_bq_opt_1.orders_with_timestamps` o
 INNER JOIN
   `cymbal_bq_opt_1.order_products` map
 ON
   o.order_id = map.order_id
 INNER JOIN
   `cymbal_bq_opt_1.products` p
 ON
   map.product_id = p.product_id )
SELECT
 order_id,
 order_ts,
 order_dow,
 order_hour_of_day,
 user_id,
 days_since_prior_order,
 order_number,
 ARRAY_AGG(product_purchased) AS order_details
FROM
 flat_orders
GROUP BY
 order_id,
 order_ts,
 order_dow,
 order_hour_of_day,
 user_id,
 days_since_prior_order,
 order_number;
'



bq query --use_legacy_sql=false \
'
WITH
 target_orders AS (
 SELECT
   order_details
 FROM
   `cymbal_bq_opt_2.orders_nested`
 WHERE
   DATE(order_ts) = "2022-08-01" )
SELECT
 product.product_name,
 COUNT(*) volume_purchased
FROM
 --https://cloud.google.com/bigquery/docs/reference/standard-sql/arrays#flattening_arrays
 target_orders,
 target_orders.order_details product
GROUP BY
 product_name
ORDER BY
 volume_purchased DESC;'


bq query --use_legacy_sql=false \
'
SELECT
 o.product_id,
 p.product_name
FROM
 `cymbal_bq_opt_1.order_products` o
 JOIN
 `cymbal_bq_opt_1.products` p
 on o.product_id = p.product_id
WHERE
 order_id = 1564244;'


bq query --use_legacy_sql=false \
'
CREATE TABLE
 cymbal_bq_opt_2.order_products
CLUSTER BY
 order_id AS
SELECT
 *
FROM
 `cymbal_bq_opt_1.order_products`;'


bq query --use_legacy_sql=false \
'
CREATE TABLE
 cymbal_bq_opt_2.products
CLUSTER BY
 product_id AS
SELECT
 *
FROM
 `cymbal_bq_opt_1.products`;'


bq query --use_legacy_sql=false \
'
SELECT
 o.product_id,
 p.product_name
FROM
 `cymbal_bq_opt_2.order_products` o
 JOIN
 `cymbal_bq_opt_2.products` p
 on o.product_id = p.product_id
WHERE
 order_id = 1564244;'


bq query --use_legacy_sql=false \
'
SELECT
TIMESTAMP_TRUNC(order_ts, HOUR) AS order_hour,
COUNT(*) AS volume_of_orders
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
GROUP BY
 order_hour
ORDER BY
 order_hour;'


bq query --use_legacy_sql=false \
'
CREATE MATERIALIZED VIEW
 `cymbal_bq_opt_1.orders_by_hour` AS (
 SELECT
   TIMESTAMP_TRUNC(order_ts, HOUR) AS order_hour,
   COUNT(*) AS volume_of_orders
 FROM
   `cymbal_bq_opt_1.orders_with_timestamps`
 GROUP BY
   order_hour );'


bq query --use_legacy_sql=false \
'
SELECT
 TIMESTAMP_TRUNC(order_ts, HOUR) AS order_hour,
 COUNT(*) AS volume_of_orders
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
GROUP BY
 order_hour
ORDER BY
 order_hour;'



bq query --use_legacy_sql=false \
'
-- orders on day with most unique customers
SELECT
 user_id,
 order_id,
 DATE(order_ts)
FROM
 `cymbal_bq_opt_1.orders_with_timestamps`
WHERE
 DATE(order_ts) = (
 SELECT
   target_date
 FROM (
   --find the date with the most unique customers
   SELECT
     DATE(order_ts) AS target_date,
     COUNT(user_id) AS customers
   FROM
     `cymbal_bq_opt_1.orders_with_timestamps`
   GROUP BY
     order_ts
   ORDER BY
     customers DESC
   LIMIT
     1 ) ) ;'


bq query --use_legacy_sql=false \
'
CREATE TABLE
cymbal_bq_opt_2.orders_with_timestamps_partition
PARTITION BY
DATE(order_ts)
AS
SELECT
*
FROM
`cymbal_bq_opt_1.orders_with_timestamps`;'


