
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone "$ZONE"

gcloud container clusters create awwvision \
    --num-nodes 2 \
    --scopes cloud-platform


gcloud container clusters get-credentials awwvision

kubectl cluster-info

sudo apt-get install -y virtualenv

python3 -m venv venv

source venv/bin/activate

gsutil -m cp -r gs://spls/gsp066/cloud-vision .


cd cloud-vision/python/awwvision

make all

kubectl get pods

sleep 5 

kubectl get pods

kubectl get deployments -o wide

kubectl get svc awwvision-webapp
