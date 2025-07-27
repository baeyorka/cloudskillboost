
gcloud auth list

bq mk --dataset Reports


bq query \
--use_legacy_sql=false \
  --destination_table=$DEVSHELL_PROJECT_ID:Reports.Trees \
  --replace=false \
  --nouse_cache \
  "SELECT
    TIMESTAMP_TRUNC(plant_date, MONTH) as plant_month,
    COUNT(tree_id) AS total_trees,
    species,
    care_taker,
    address,
    site_info
  FROM
    \`bigquery-public-data.san_francisco_trees.street_trees\`
  WHERE
    address IS NOT NULL
    AND plant_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
    AND plant_date < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
  GROUP BY
    plant_month,
    species,
    care_taker,
    address,
    site_info"

echo ""

echo -e "\e[1;34mClick Here to open\e[0m \e[1;32mhttps://lookerstudio.google.com/\e[0m"

echo ""
