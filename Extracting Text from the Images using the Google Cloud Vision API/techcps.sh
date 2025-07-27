
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com


export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")


gcloud storage buckets create gs://$DEVSHELL_PROJECT_ID-image --location=$REGION

gcloud storage buckets create gs://$DEVSHELL_PROJECT_ID-result --location=$REGION

gcloud pubsub topics create techcps-translate

gcloud pubsub topics create techcps-result

git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

cd python-docs-samples/functions/ocr/app/

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')

SERVICE_ACCOUNT=$(gcloud storage service-agent --project=$PROJECT_ID)

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

#!/bin/bash

deploy_function() {
  gcloud functions deploy ocr-extract \
  --gen2 \
  --runtime python312 \
  --region=$REGION \
  --source=. \
  --entry-point process_image \
  --trigger-bucket $DEVSHELL_PROJECT_ID-image \
  --service-account $PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --allow-unauthenticated \
  --set-env-vars "^:^GCP_PROJECT=$PROJECT_ID:TRANSLATE_TOPIC=techcps-translate:RESULT_TOPIC=techcps-result:TO_LANG=es,en,fr,ja"
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully.[https://www.youtube.com/@techcps].."
    deploy_success=true
  else
    echo "Please subscribe to Techcps.[https://www.youtube.com/@techcps].."
    sleep 10
  fi
done


deploy_function() {
 gcloud functions deploy ocr-translate \
 --gen2 \
 --runtime python312 \
 --region=$REGION \
 --source=. \
 --trigger-topic techcps-result \
 --entry-point translate_text \
 --service-account $PROJECT_NUMBER-compute@developer.gserviceaccount.com \
 --allow-unauthenticated \
 --set-env-vars "GCP_PROJECT=$PROJECT_ID,RESULT_TOPIC=$_techcps-result"

}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully.[https://www.youtube.com/@techcps].."
    deploy_success=true
  else
    echo "Please subscribe to Techcps.[https://www.youtube.com/@techcps].."
    sleep 10
  fi
done


deploy_function() {
 gcloud functions deploy ocr-save \
 --gen2 \
 --runtime python312 \
 --region=$REGION \
 --source=. \
 --trigger-topic techcps-result \
 --entry-point save_result \
 --service-account $PROJECT_NUMBER-compute@developer.gserviceaccount.com \
 --allow-unauthenticated \
 --set-env-vars "GCP_PROJECT=$PROJECT_ID,RESULT_BUCKET=$DEVSHELL_PROJECT_ID-result"
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully.[https://www.youtube.com/@techcps].."
    deploy_success=true
  else
    echo "Please subscribe to Techcps.[https://www.youtube.com/@techcps].."
    sleep 10
  fi
done


gsutil cp gs://cloud-training/OCBL307/menu.jpg .

gsutil cp menu.jpg gs://$DEVSHELL_PROJECT_ID-image


gcloud functions logs read --limit 100


