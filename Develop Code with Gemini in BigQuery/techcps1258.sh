

export PROJECT_ID=$(gcloud config get-value project)

echo $PROJECT_ID


bq query --use_legacy_sql=false \
"SELECT
  item_price
FROM
  \`${PROJECT_ID}.coffee_on_wheels.menu\`;"



bq query --use_legacy_sql=false \
"SELECT
  \`menu_id\`,
  \`order_id\`,
  \`order_item_id\`
FROM
  \`${PROJECT_ID}.coffee_on_wheels.order_item\`;"





bq query --use_legacy_sql=false \
"(
     SELECT
         menu_id,
         SUM(item_total) AS total_revenue
     FROM
         \`${PROJECT_ID}.coffee_on_wheels.order_item\`
     GROUP BY 1
     ORDER BY
         total_revenue DESC
     LIMIT 3
 )
 UNION ALL
 (
     SELECT
         menu_id,
         SUM(item_total) AS total_revenue
     FROM
         \`${PROJECT_ID}.coffee_on_wheels.order_item\`
     GROUP BY 1
     ORDER BY
         total_revenue
     LIMIT 3
 );"




bq query --use_legacy_sql=false \
"(
    SELECT
        t1.menu_id,
        t1.item_name,
        SUM(t2.item_total) AS total_revenue
    FROM
        \`${PROJECT_ID}.coffee_on_wheels.menu\` AS t1
    INNER JOIN
        \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS t2
    ON
        t1.menu_id = t2.menu_id
    GROUP BY
        t1.menu_id, t1.item_name
    ORDER BY
        total_revenue DESC
    LIMIT 3
)
UNION ALL
(
    SELECT
        t1.menu_id,
        t1.item_name,
        SUM(t2.item_total) AS total_revenue
    FROM
        \`${PROJECT_ID}.coffee_on_wheels.menu\` AS t1
    INNER JOIN
        \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS t2
    ON
        t1.menu_id = t2.menu_id
    GROUP BY
        t1.menu_id, t1.item_name
    ORDER BY
        total_revenue
    LIMIT 3
);
"



bq query --use_legacy_sql=false \
"(
     SELECT
         t1.menu_id,
         t1.item_name,
         ROUND(SUM(t2.item_total), 2) AS total_revenue
     FROM
         \`${PROJECT_ID}.coffee_on_wheels.menu\` AS t1
         INNER JOIN \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS t2 ON t1.menu_id = t2.menu_id
     GROUP BY 1, 2
     ORDER BY
         total_revenue DESC
     LIMIT 3
 )
 UNION ALL
 (
     SELECT
         t1.menu_id,
         t1.item_name,
         ROUND(SUM(t2.item_total), 2) AS total_revenue
     FROM
         \`${PROJECT_ID}.coffee_on_wheels.menu\` AS t1
         INNER JOIN \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS t2 ON t1.menu_id = t2.menu_id
     GROUP BY 1, 2
     ORDER BY
         total_revenue
     LIMIT 3
 );"



bq query --use_legacy_sql=false \
"SELECT
     oi.menu_id,
     m.item_name,
     SUM(oi.item_total) AS total_revenue
 FROM
     \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS oi
     INNER JOIN \`${PROJECT_ID}.coffee_on_wheels.menu\` AS m ON oi.menu_id = m.menu_id
 WHERE m.item_size = 'Small'
 GROUP BY 1, 2
 ORDER BY
     total_revenue DESC
 LIMIT 10;"


bq query --use_legacy_sql=false \
"SELECT
     oi.menu_id,
     m.item_name,
     ROUND(SUM(oi.item_total), 2) AS total_revenue  -- Round to 2 decimal places
 FROM
     \`${PROJECT_ID}.coffee_on_wheels.order_item\` AS oi
     INNER JOIN \`${PROJECT_ID}.coffee_on_wheels.menu\` AS m ON oi.menu_id = m.menu_id
 WHERE m.item_size = 'Small'
 GROUP BY 1, 2
 ORDER BY
     total_revenue DESC
 LIMIT 10;"



