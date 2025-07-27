

gcloud auth list

gcloud services enable run.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/zone "$ZONE"

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region "$REGION"


curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

unzip main.zip

cd golang-samples-main/functions/codelabs/gopher


#!/bin/bash

deploy_function() {
 gcloud functions deploy HelloWorld --gen2 --runtime go121 --trigger-http --region $REGION --quiet
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully! Check it out: https://www.youtube.com/@techcps"
    deploy_success=true
  else
    echo "Deployment failed. Please subscribe to techcps: https://www.youtube.com/@techcps"
    sleep 10
  fi
done


deploy_function() {
 gcloud functions deploy Gopher --gen2 --runtime go121 --trigger-http --region $REGION --quiet
}

deploy_success=false

while [ "$deploy_success" = false ]; do
  if deploy_function; then
    echo "Function deployed successfully! Check it out: https://www.youtube.com/@techcps"
    deploy_success=true
  else
    echo "Deployment failed. Please subscribe to techcps: https://www.youtube.com/@techcps"
    sleep 10
  fi
done

