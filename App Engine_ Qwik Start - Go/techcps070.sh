

gcloud auth list

gcloud services enable appengine.googleapis.com

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region $REGION

git clone https://github.com/GoogleCloudPlatform/golang-samples.git

cd golang-samples/appengine/go11x/helloworld

sudo apt-get install google-cloud-sdk-app-engine-go

gcloud app create --project=$PROJECT_ID --region=$REGION

gcloud app deploy --project=$PROJECT_ID --quiet
