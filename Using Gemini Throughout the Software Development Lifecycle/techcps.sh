

gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/region "$REGION"

PROJECT_ID=$(gcloud config get-value project)
echo "PROJECT_ID=${PROJECT_ID}"

USER=$(gcloud config get-value account 2> /dev/null)
echo "USER=${USER}"

gcloud services enable cloudaicompanion.googleapis.com --project ${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudaicompanion.user
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/serviceusage.serviceUsageViewer

gcloud auth configure-docker

gcloud storage cp -r gs://cloud-training/OCBL435/cymbal-superstore .

cd ~/cymbal-superstore/backend
docker build --platform linux/amd64 -t gcr.io/${PROJECT_ID}/cymbal-inventory-api .

docker push gcr.io/${PROJECT_ID}/cymbal-inventory-api

bq load --source_format=CSV --autodetect cymbal_sales.cymbalsalestable gs://$DEVSHELL_PROJECT_ID-cymbal-frontend/sales_bq_rawdata.csv

bq show --format=prettyjson $DEVSHELL_PROJECT_ID:cymbal_sales.cymbalsalestable

bq query --use_legacy_sql=false "SELECT * FROM \`${DEVSHELL_PROJECT_ID}.cymbal_sales.cymbalsalestable\` LIMIT 10;"

bq query --use_legacy_sql=false "
SELECT SUM(PRICE_PER_UNIT * QUANTITY_SOLD_AUG_5) AS total_aug_5 
FROM \`${DEVSHELL_PROJECT_ID}.cymbal_sales.cymbalsalestable\`;
"

bq query --use_legacy_sql=false "
SELECT SUM(PRICE_PER_UNIT * QUANTITY_SOLD_AUG_12) AS total_aug_12 
FROM \`${DEVSHELL_PROJECT_ID}.cymbal_sales.cymbalsalestable\`;
"

bq query --use_legacy_sql=false "
SELECT * FROM \`${DEVSHELL_PROJECT_ID}.cymbal_sales.cymbalsalestable\` 
LIMIT 10;
"

gcloud run deploy inventory --image=gcr.io/${PROJECT_ID}/cymbal-inventory-api --port=8000 --region=$REGION --set-env-vars=PROJECT_ID=${PROJECT_ID} --allow-unauthenticated

