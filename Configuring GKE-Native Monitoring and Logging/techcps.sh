

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export my_zone=$ZONE
export my_cluster=standard-cluster-1

source <(kubectl completion bash)

gcloud container clusters create $my_cluster \
   --num-nodes 3 --enable-ip-alias --zone $my_zone  \
   --logging=SYSTEM \
   --monitoring=SYSTEM

gcloud container clusters get-credentials $my_cluster --zone $my_zone

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s

cd ~/ak8s/Monitoring/

kubectl create -f hello-v2.yaml


kubectl get deployments

export PROJECT_ID="$(gcloud config get-value project -q)"

cd gcp-gke-monitor-test

gcloud builds submit --tag=gcr.io/$PROJECT_ID/gcp-gke-monitor-test .

docker build -t gcr.io/${PROJECT_ID}/gcp-gke-monitor-test .

cd ..

sed -i "s/\[DOCKER-IMAGE\]/gcr\.io\/${PROJECT_ID}\/gcp-gke-monitor-test\:latest/" gcp-gke-monitor-test.yaml

kubectl create -f gcp-gke-monitor-test.yaml

kubectl get deployments

kubectl get service


cat > cp-channel.json <<EOF_CP
{
  "type": "pubsub",
  "displayName": "techcps",
  "description": "subscribe to techcps",
  "labels": {
    "topic": "projects/$DEVSHELL_PROJECT_ID/topics/notificationTopic"
  }
}
EOF_CP


gcloud beta monitoring channels create --channel-content-from-file=cp-channel.json


email_channel=$(gcloud beta monitoring channels list)
channel_id=$(echo "$email_channel" | grep -oP 'name: \K[^ ]+' | head -n 1)

cat > cp-policy.json <<EOF_CP
{
  "displayName": "CPU request utilization",
  "combiner": "AND",
  "conditions": [
    {
      "displayName": "CPU request utilization above 99%",
      "conditionThreshold": {
        "filter": "resource.type=\"k8s_container\" AND metric.type=\"kubernetes.io/container/cpu/request_utilization\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_MEAN"
          }
        ],
        "comparison": "COMPARISON_GT",
        "thresholdValue": 0.99,
        "duration": "60s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "notificationChannels": ["$channel_id"],
  "enabled": true
}
EOF_CP


gcloud alpha monitoring policies create --policy-from-file=cp-policy.json


