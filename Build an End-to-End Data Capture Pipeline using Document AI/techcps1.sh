


gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud services enable documentai.googleapis.com      
gcloud services enable cloudfunctions.googleapis.com  
gcloud services enable cloudbuild.googleapis.com    
gcloud services enable geocoding-backend.googleapis.com   

gcloud alpha services api-keys create --display-name="techcps" --project=$DEVSHELL_PROJECT_ID

sleep 20

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=techcps")

export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

export PROCESSOR_NAME=form-processor

ACCESS_TOKEN=$(gcloud auth application-default print-access-token)

curl -X PATCH \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "restrictions": {
      "apiTargets": [
        {
          "service": "geocoding-backend.googleapis.com"
        }
      ]
    }
  }' \
  "https://apikeys.googleapis.com/v2/$KEY_NAME?updateMask=restrictions"


mkdir ./documentai-pipeline-demo
gcloud storage cp -r \
  gs://spls/gsp927/documentai-pipeline-demo/* \
  ~/documentai-pipeline-demo/

curl -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "'"$PROCESSOR_NAME"'",
    "type": "FORM_PARSER_PROCESSOR"
  }' \
  "https://documentai.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/us/processors"


export PROJECT_ID=$(gcloud config get-value core/project)
export BUCKET_LOCATION="$REGION"
gsutil mb -c standard -l ${BUCKET_LOCATION} -b on \
  gs://${PROJECT_ID}-input-invoices
gsutil mb -c standard -l ${BUCKET_LOCATION} -b on \
  gs://${PROJECT_ID}-output-invoices
gsutil mb -c standard -l ${BUCKET_LOCATION} -b on \
  gs://${PROJECT_ID}-archived-invoices


bq --location="US" mk  -d \
    --description "Form Parser Results" \
    ${PROJECT_ID}:invoice_parser_results
cd ~/documentai-pipeline-demo/scripts/table-schema/
bq mk --table \
  invoice_parser_results.doc_ai_extracted_entities \
  doc_ai_extracted_entities.json
bq mk --table \
  invoice_parser_results.geocode_details \
  geocode_details.json

export GEO_CODE_REQUEST_PUBSUB_TOPIC=geocode_request
gcloud pubsub topics \
  create ${GEO_CODE_REQUEST_PUBSUB_TOPIC}


gcloud storage service-agent --project=$PROJECT_ID

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcloud iam service-accounts create "service-$PROJECT_NUMBER" \
  --display-name "Cloud Storage Service Account" || true

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:service-$PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:service-$PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountTokenCreator"


  cd ~/documentai-pipeline-demo/scripts
  export CLOUD_FUNCTION_LOCATION="$REGION"

deploy_function() {
  gcloud functions deploy process-invoices \
  --no-gen2 \
  --region=${CLOUD_FUNCTION_LOCATION} \
  --entry-point=process_invoice \
  --runtime=python39 \
  --source=cloud-functions/process-invoices \
  --timeout=400 \
  --env-vars-file=cloud-functions/process-invoices/.env.yaml \
  --trigger-resource=gs://${PROJECT_ID}-input-invoices \
  --trigger-event=google.storage.object.finalize
}

SERVICE_NAME="process-invoices"

while true; do
  deploy_function
  if gcloud functions describe $SERVICE_NAME --region $CLOUD_FUNCTION_LOCATION &> /dev/null; then
    echo "Cloud Function deployed successfully!"
    break
  else
    echo "Retrying deploy for process-invoices"
    echo "please subscribe to techcps https://www.youtube.com/@techcps"
    sleep 30
  fi
done

 cd
 cd ~/documentai-pipeline-demo/scripts

deploy_function() {
  gcloud functions deploy geocode-addresses \
  --no-gen2 \
  --region=${CLOUD_FUNCTION_LOCATION} \
  --entry-point=process_address \
  --runtime=python39 \
  --source=cloud-functions/geocode-addresses \
  --timeout=60 \
  --env-vars-file=cloud-functions/geocode-addresses/.env.yaml \
  --trigger-topic=${GEO_CODE_REQUEST_PUBSUB_TOPIC}
}

SERVICE_NAME="geocode-addresses"

while true; do
  deploy_function
  if gcloud functions describe $SERVICE_NAME --region $CLOUD_FUNCTION_LOCATION &> /dev/null; then
    echo "Cloud Function deployed successfully!"
    break
  else
    echo "Retrying deploy for geocode-addresses"
    echo "please subscribe to techcps https://www.youtube.com/@techcps"
    sleep 30
  fi
done

PROCESSOR_ID=$(curl -X GET \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://documentai.googleapis.com/v1/projects/$PROJECT_ID/locations/us/processors" | \
  grep '"name":' | \
  sed -E 's/.*"name": "projects\/[0-9]+\/locations\/us\/processors\/([^"]+)".*/\1/')

echo "$PROCESSOR_ID"
export PROCESSOR_ID

gcloud functions deploy process-invoices \
  --no-gen2 \
  --region="${CLOUD_FUNCTION_LOCATION}" \
  --entry-point=process_invoice \
  --runtime=python39 \
  --source=cloud-functions/process-invoices \
  --timeout=400 \
  --update-env-vars=PROCESSOR_ID=${PROCESSOR_ID},PARSER_LOCATION=us,GCP_PROJECT=${PROJECT_ID} \
  --trigger-resource=gs://${PROJECT_ID}-input-invoices \
  --trigger-event=google.storage.object.finalize

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=techcps")

export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

gcloud functions deploy geocode-addresses \
  --no-gen2 \
  --region="${CLOUD_FUNCTION_LOCATION}" \
  --entry-point=process_address \
  --runtime=python39 \
  --source=cloud-functions/geocode-addresses \
  --timeout=60 \
  --update-env-vars=API_key=${API_KEY} \
  --trigger-topic=${GEO_CODE_REQUEST_PUBSUB_TOPIC}


export PROJECT_ID=$(gcloud config get-value core/project)
gsutil cp gs://spls/gsp927/documentai-pipeline-demo/sample-files/* gs://${PROJECT_ID}-input-invoices/



