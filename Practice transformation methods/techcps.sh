


bq query --use_legacy_sql=false \
' SELECT * FROM
 `thelook_ecommerce.products`
 LIMIT 10;'


bq query --use_legacy_sql=false \
'SELECT
COUNT(*) AS NumberOfRows,
COUNT(DISTINCT name) AS NumberofProducts
FROM `thelook_ecommerce.products`;'


bq query --use_legacy_sql=false \
'SELECT category, COUNT(*) AS itemCount
FROM `thelook_ecommerce.products`
GROUP BY category;'


bq query --use_legacy_sql=false \
'SELECT segment, COUNT(*) AS itemCount
FROM `thelook_ecommerce.products`
GROUP BY segment;'


bq query --use_legacy_sql=false \
'SELECT category, COUNT(*) AS itemCount
FROM `thelook_ecommerce.products`
GROUP BY category
HAVING  itemCount > 1000;'



bq query --use_legacy_sql=false \
'SELECT * FROM
`thelook_ecommerce.products`
TABLESAMPLE SYSTEM (10 PERCENT);'

bq query --use_legacy_sql=false \
'SELECT * FROM
`thelook_ecommerce.order_items`
LIMIT 10;'

bq query --use_legacy_sql=false \
'SELECT status, COUNT(*) AS total_orders
FROM
`thelook_ecommerce.order_items`
GROUP BY status;'

bq query --use_legacy_sql=false \
'SELECT user_id,
SUM(sale_price) AS total_amount
FROM
`thelook_ecommerce.order_items`
GROUP BY user_id
ORDER BY total_amount DESC
LIMIT 1;'


