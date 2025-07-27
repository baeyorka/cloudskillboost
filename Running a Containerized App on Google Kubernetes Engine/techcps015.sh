
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud config set compute/zone "$ZONE"

gcloud container clusters create hello-world --zone="$ZONE"

echo $DEVSHELL_PROJECT_ID

git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

cd kubernetes-engine-samples/quickstarts/hello-app

cat Dockerfile

docker build -t gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0 .

gcloud docker -- push gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0

kubectl create deployment hello-app --image=gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0

kubectl get deployments

kubectl get pods

kubectl expose deployment hello-app --name=hello-app --type=LoadBalancer --port=80 --target-port=8080

kubectl get svc hello-app

