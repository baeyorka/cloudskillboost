

export PROJECT=$(gcloud projects list --format="value(PROJECT_ID)")

# export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gsutil cp customers.csv gs://$PROJECT-bucket/customers.csv

bq load \
    --source_format=CSV \
    --autodetect \
    --replace \
    customer_details.customers \
    gs://$PROJECT-bucket/customers.csv


bq query --use_legacy_sql=false \
'CREATE TABLE customer_details.male_customers AS
 SELECT CustomerID, Gender
 FROM customer_details.customers
 WHERE Gender = "Male"'


bq extract \
    --destination_format=CSV \
    --compression=NONE \
    customer_details.male_customers \
    gs://$PROJECT-bucket/exported_male_customers.csv


