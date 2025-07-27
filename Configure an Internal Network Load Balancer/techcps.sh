
# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)


gcloud auth list

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the ZONE: ${RESET}" ZONE

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region "$REGION"

gcloud compute firewall-rules create fw-allow-lb-access \
  --description="subscribe to techcps" \
  --network=my-internal-app \
  --allow=all \
  --source-ranges=10.10.0.0/16 \
  --target-tags=backend-service


gcloud compute firewall-rules create fw-allow-health-checks \
  --description="subscribe to techcps" \
  --network=my-internal-app \
  --allow=tcp:80 \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=backend-service



gcloud compute routers create nat-router-$REGION \
  --region=$REGION \
  --network=my-internal-app \
  --description="subscribe to techcps"


gcloud compute routers nats create nat-config \
  --region=$REGION \
  --router=nat-router-$REGION \
  --nat-all-subnet-ip-ranges \
  --auto-allocate-nat-external-ips \
  --enable-logging

### Task 3

# export IG1=$(gcloud compute instances list \
#  --filter="name~'^instance-group-1'" \
#  --format="value(name)" | head -n1)

# export ZONE1=$(gcloud compute instances list \
#  --filter="name=$IG1" \
#  --format="value(zone)")

# gcloud compute ssh "$IG1" \
#  --zone="$ZONE1" \
#  --tunnel-through-iap \
#  --project="$DEVSHELL_PROJECT_ID" \
#  --quiet \
#  --command="sudo google_metadata_script_runner startup"


# export IG2=$(gcloud compute instances list \
#  --filter="name~'^instance-group-2'" \
#  --format="value(name)" | head -n1)

# export ZONE2=$(gcloud compute instances list \
#  --filter="name=$IG2" \
#  --format="value(zone)")

# gcloud compute ssh "$IG2" \
#  --zone="$ZONE2" \
#  --tunnel-through-iap \
#  --project="$DEVSHELL_PROJECT_ID" \
#  --quiet \
#  --command="sudo google_metadata_script_runner startup"


gcloud compute instances create utility-vm --project "$DEVSHELL_PROJECT_ID" --zone=$ZONE --machine-type=e2-medium --subnet=subnet-a --private-network-ip=10.10.20.50 --no-address --image-family=debian-12 --image-project=debian-cloud --tags=backend-service --description="subscribe to techcps"


### Task 4

gcloud compute addresses create my-ilb-ip \
  --region=$REGION \
  --subnet=subnet-b \
  --addresses=10.10.30.5 \
  --purpose=GCE_ENDPOINT \
  --description="subscribe to techcps"


gcloud compute health-checks create tcp my-ilb-health-check \
  --port=80 \
  --check-interval=10s \
  --timeout=5s \
  --unhealthy-threshold=3 \
  --healthy-threshold=2 \
  --description="subscribe to techcps"

gcloud compute backend-services create my-ilb-backend-service \
  --load-balancing-scheme=internal \
  --protocol=TCP \
  --region=$REGION \
  --health-checks=my-ilb-health-check \
  --description="subscribe to techcps"


gcloud compute backend-services add-backend my-ilb-backend-service \
  --instance-group=instance-group-1 \
  --instance-group-zone=$ZONE1 \
  --region=$REGION


gcloud compute backend-services add-backend my-ilb-backend-service \
  --instance-group=instance-group-2 \
  --instance-group-zone=$ZONE2 \
  --region=$REGION


gcloud compute forwarding-rules create my-ilb \
  --load-balancing-scheme=internal \
  --ports=80 \
  --network=my-internal-app \
  --subnet=subnet-b \
  --region=$REGION \
  --backend-service=my-ilb-backend-service \
  --backend-service-region=$REGION \
  --address=my-ilb-ip \
  --description="subscribe to techcps"


