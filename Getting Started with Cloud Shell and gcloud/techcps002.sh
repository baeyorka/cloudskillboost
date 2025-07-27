

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances create gcelab2 --project=$DEVSHELL_PROJECT_ID --zone $ZONE --machine-type e2-medium

gcloud compute instances add-tags gcelab2 --project=$DEVSHELL_PROJECT_ID --zone $ZONE --tags http-server,https-server

gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

