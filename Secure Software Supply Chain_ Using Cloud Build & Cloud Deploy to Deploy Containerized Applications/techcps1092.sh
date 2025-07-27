


gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT=$(gcloud config get-value project)
export PROJECT_ID=$PROJECT

gcloud services enable run.googleapis.com
gcloud services enable clouddeploy.googleapis.com

gcloud artifacts repositories create helloworld-repo --location=$REGION --repository-format=docker --project=$PROJECT


mkdir helloworld
cd helloworld

cat > package.json <<'EOF_CP'
{
  "name": "helloworld",
  "description": "Simple hello world sample in Node",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "engines": {
    "node": ">=12.0.0"
  },
  "author": "Google LLC",
  "license": "Apache-2.0",
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF_CP


cat > index.js <<'EOF_CP'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  const name = process.env.NAME || 'World';
  res.send(`Hello ${name}!`);
});

const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`helloworld: listening on port ${port}`);
});
EOF_CP

# cd ~/helloworld

gcloud builds submit --pack image=$REGION-docker.pkg.dev/$PROJECT/helloworld-repo/helloworld


mkdir ~/deploy-cloudrun
cd ~/deploy-cloudrun




cat > skaffold.yaml <<'EOF_CP'
apiVersion: skaffold/v3alpha1
kind: Config
metadata:
  name: deploy-run-quickstart
profiles:
- name: dev
  manifests:
    rawYaml:
    - run-dev.yaml
- name: prod
  manifests:
    rawYaml:
    - run-prod.yaml
deploy:
  cloudrun: {}
EOF_CP




cat > run-dev.yaml <<'EOF_CP'
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-dev
spec:
  template:
    spec:
      containers:
      - image: my-app-image
EOF_CP


cat > run-prod.yaml <<'EOF_CP'
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-prod
spec:
  template:
    spec:
      containers:
      - image: my-app-image
EOF_CP


cat > clouddeploy.yaml <<EOF_CP
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
 name: my-run-demo-app-1
description: main application pipeline
serialPipeline:
 stages:
 - targetId: run-dev
   profiles: [dev]
 - targetId: run-prod
   profiles: [prod]
---
  
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
 name: run-dev
description: Cloud Run development service
run:
 location: projects/$PROJECT_ID/locations/$REGION
---

apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
 name: run-prod
description: Cloud Run production service
run:
 location: projects/$PROJECT_ID/locations/$REGION
EOF_CP



gcloud deploy apply --file clouddeploy.yaml --region=$REGION

gcloud deploy releases create run-release-001 --project=$PROJECT --region=$REGION --delivery-pipeline=my-run-demo-app-1 --images=my-app-image="$REGION-docker.pkg.dev/$PROJECT/helloworld-repo/helloworld"

gcloud deploy releases promote --release=run-release-001 --region=$REGION --delivery-pipeline=my-run-demo-app-1 --to-target=run-prod --quiet


