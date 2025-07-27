
gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud container clusters create-auto autopilot-cluster-1 --region=$REGION

sleep 10

kubectl create deployment nginx-1 --image=nginx:latest
