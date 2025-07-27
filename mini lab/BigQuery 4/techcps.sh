

export PROJECT=$(gcloud projects list --format="value(PROJECT_ID)")

bq load --source_format=CSV --autodetect products.products_information gs://$PROJECT-bucket/products.csv 

bq query --use_legacy_sql=false "CREATE SEARCH INDEX IF NOT EXISTS products.p_i_search_index ON products.products_information (ALL COLUMNS);"

bq query --use_legacy_sql=false "SELECT * FROM products.products_information WHERE SEARCH(STRUCT(), '22 oz Water Bottle') = TRUE;"

