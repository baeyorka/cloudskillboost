

bq query --use_legacy_sql=false '
CREATE OR REPLACE EXTERNAL TABLE `thelook_gcda.product_returns`
OPTIONS (
  format="PARQUET",
  uris=["gs://sureskills-lab-dev/DAC2M2L4/returns/returns_*.parquet"]
);
'


bq query --use_legacy_sql=false \
"
SELECT COUNT(*) AS row_count
FROM \`thelook_gcda.product_returns\`;
"


bq query --use_legacy_sql=false \
"
SELECT *
FROM \`thelook_gcda.product_returns\`
ORDER BY status_date desc
LIMIT 10;
"

bq query --use_legacy_sql=false \
"
SELECT dc.name, pr.*
FROM \`thelook_gcda.product_returns\` AS pr
INNER JOIN \`thelook_gcda.distribution_centers\` AS dc
ON dc.id = pr.distribution_center_id;
"


bq query --nouse_legacy_sql '
SELECT
  dc.name AS distribution_center,
  p.category,
  COUNT(*) AS product_return_count
FROM `thelook_gcda.product_returns` AS pr
INNER JOIN `thelook_gcda.distribution_centers` AS dc
ON dc.id = pr.distribution_center_id
INNER JOIN `thelook_gcda.products` p
ON p.id = pr.product_id
WHERE p.category = "Jeans"
GROUP BY dc.name, p.category;
'



BUCKET_NAME="sureskills-lab-dev"
FILE_PATH="DAC2M2L4/price_update/price_update_shirts.csv"
DATASET_NAME="thelook_gcda"
TABLE_NAME="shirt_price_update"


bq load \
  --source_format=CSV \
  --autodetect \
  $DATASET_NAME.$TABLE_NAME \
  gs://$BUCKET_NAME/$FILE_PATH



