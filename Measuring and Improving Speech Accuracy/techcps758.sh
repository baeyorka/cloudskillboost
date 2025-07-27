
gcloud auth list

gcloud auth list && gcloud services enable compute.googleapis.com iam.googleapis.com iamcredentials.googleapis.com monitoring.googleapis.com logging.googleapis.com notebooks.googleapis.com aiplatform.googleapis.com bigquery.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com container.googleapis.com

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud notebooks instances create lab-workbench --location=$ZONE --vm-image-project=deeplearning-platform-release --vm-image-family=tf-latest-cpu

echo ""

echo "https://console.cloud.google.com/vertex-ai/workbench?invt=Abt5hQ&project=$DEVSHELL_PROJECT_ID"

echo ""
