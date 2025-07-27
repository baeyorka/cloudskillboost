

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT --location=$REGION

gcloud storage cp -r gs://configuring-singlestore-on-gcp/drivers gs://$GOOGLE_CLOUD_PROJECT

gcloud storage cp -r gs://configuring-singlestore-on-gcp/trips gs://$GOOGLE_CLOUD_PROJECT

gcloud storage cp gs://configuring-singlestore-on-gcp/neighborhoods.csv gs://$GOOGLE_CLOUD_PROJECT

gcloud dataflow jobs run "GCStoPS-clone" \
  --region=$REGION \
  --gcs-location=gs://dataflow-templates-$REGION/latest/Stream_GCS_Text_to_Cloud_PubSub \
  --parameters \
inputFilePattern=gs://$GOOGLE_CLOUD_PROJECT/input/*.json,\
outputTopic=projects/$(gcloud config get-value project)/topics/Taxi

gcloud pubsub subscriptions pull \
  projects/$(gcloud config get-value project)/subscriptions/Taxi-sub \
  --limit=10 \
  --auto-ack

gcloud dataflow flex-template run pstogcs \
  --region=$REGION \
  --template-file-gcs-location=gs://dataflow-templates-$REGION/latest/flex/Cloud_PubSub_to_GCS_Text_Flex \
  --parameters \
inputSubscription=projects/$(gcloud config get-value project)/subscriptions/Taxi-sub,\
outputDirectory=gs://$GOOGLE_CLOUD_PROJECT,\
outputFilenamePrefix=output

echo ""

echo -e "\033[1;33mOpen this link\033[0m \033[1;34mhttps://console.cloud.google.com/dataflow/jobs?project=$DEVSHELL_PROJECT_ID\033[0m"

echo ""
