

gcloud auth list && gcloud services enable compute.googleapis.com iam.googleapis.com iamcredentials.googleapis.com monitoring.googleapis.com logging.googleapis.com notebooks.googleapis.com aiplatform.googleapis.com bigquery.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com container.googleapis.com

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo $REGION

gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID

echo ""

echo "https://console.cloud.google.com/vertex-ai?invt=Abm5Fg&project=$DEVSHELL_PROJECT_ID"

echo ""

