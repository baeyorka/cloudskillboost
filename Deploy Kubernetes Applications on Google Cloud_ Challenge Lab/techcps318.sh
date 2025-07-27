


# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the REPO_NAME: ${RESET}" REPO_NAME
read -p "${YELLOW}${BOLD}Enter the DOCKER_IMAGE: ${RESET}" DOCKER_IMAGE
read -p "${YELLOW}${BOLD}Enter the TAG_NAME: ${RESET}" TAG_NAME

# Export variables after collecting input
export REPO_NAME DOCKER_IMAGE TAG_NAME

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)

gsutil cp gs://spls/gsp318/valkyrie-app.tgz .
tar -xzf valkyrie-app.tgz
cd valkyrie-app

cat > Dockerfile <<EOF_CP
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF_CP


docker build -t $DOCKER_IMAGE:$TAG_NAME .

bash ~/marking/step1_v2.sh



cd ..
cd valkyrie-app
docker run -p 8080:8080 $DOCKER_IMAGE:$TAG_NAME &
cd ..
cd marking
./step2_v2.sh
bash ~/marking/step2_v2.sh

cd ..
cd valkyrie-app



gcloud artifacts repositories create $REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="subcribe to techcps" \
    --async 

gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

sleep 30

Image_ID=$(docker images --format='{{.ID}}')

docker tag $Image_ID $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO_NAME/$DOCKER_IMAGE:$TAG_NAME

docker push $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO_NAME/$DOCKER_IMAGE:$TAG_NAME

gcloud artifacts docker images list $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO_NAME

cd marking/valkyrie-app/k8s


sed -i s#IMAGE_HERE#$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/$REPO_NAME/$DOCKER_IMAGE:$TAG_NAME#g ~/marking/valkyrie-app/k8s/deployment.yaml

gcloud container clusters list

gcloud container clusters get-credentials valkyrie-dev --zone $ZONE --project $DEVSHELL_PROJECT_ID

# kubectl create -f k8s/deployment.yaml
# kubectl create -f k8s/service.yaml

kubectl apply -f ~/marking/valkyrie-app/k8s/deployment.yaml
kubectl apply -f ~/marking/valkyrie-app/k8s/service.yaml

kubectl get pods
kubectl get services


