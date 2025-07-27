

export BUCKET=$GOOGLE_CLOUD_PROJECT
gcloud storage buckets create gs://$BUCKET

SERVICE_ACCOUNT=$(gcloud iam service-accounts list --filter="email~'-compute@developer.gserviceaccount.com'" --format="value(email)")
echo $SERVICE_ACCOUNT

export PROJECT_ID=$(gcloud config get-value project)

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$SERVICE_ACCOUNT" \
--role="roles/datafusion.serviceAgent"

gcloud projects get-iam-policy $PROJECT_ID \
--flatten="bindings[].members" \
--filter="bindings.members:$SERVICE_ACCOUNT" \
--format="table(bindings.role)"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/iam.serviceAccountUser" \
  --condition=None


PROJECT_ID=$(gcloud config get-value project)
echo $PROJECT_ID

gcloud projects describe $PROJECT_ID

SERVICE_ACCOUNT_NAME="service-$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")@gcp-sa-datafusion.iam.gserviceaccount.com"
echo $SERVICE_ACCOUNT_NAME

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME" \
  --role="roles/dlp.admin"

gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT_NAME"


