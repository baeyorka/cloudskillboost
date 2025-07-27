
export PROJECT=$(gcloud config get-value project)

REGION='us'

bq query \
--use_legacy_sql=false \
--destination_table=ecommerce.backup_orders \
--display_name='Subscribe to Techcps' \
--schedule='1 of month 00:00' \
--replace=true \
'CREATE OR REPLACE TABLE ecommerce.backup_orders AS
SELECT * FROM ecommerce.customer_orders;'


bq mk --transfer_config \
  --project_id=$PROJECT \
  --data_source=scheduled_query \
  --target_dataset=ecommerce \
  --display_name="Subscribe to Techcps" \
  --schedule="1 of month 00:00" \
  --params='{"query":"SELECT * FROM `'${PROJECT}'.ecommerce.customer_orders`", "destination_table_name_template":"backup_orders", "write_disposition":"WRITE_TRUNCATE"}'


  
