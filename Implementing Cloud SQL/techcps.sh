
gcloud auth list

export ZONE=$(gcloud compute instances list --project="$DEVSHELL_PROJECT_ID" --format="value(zone)" | head -n 1)

export REGION="${ZONE%-*}"

gcloud services enable vpcaccess.googleapis.com servicenetworking.googleapis.com

gcloud compute addresses create google-managed-services-default \
  --global --project=$DEVSHELL_PROJECT_ID \
  --purpose=VPC_PEERING \
  --prefix-length=16 \
  --description="subscribe to techcps" \
  --network=default

gcloud services vpc-peerings connect \
  --project=$DEVSHELL_PROJECT_ID \
  --service=servicenetworking.googleapis.com \
  --ranges=google-managed-services-default \
  --network=default



gcloud beta sql instances create wordpress-db \
  --region=$REGION \
  --database-version=MYSQL_5_7 \
  --root-password=subscribe_to_techcps \
  --tier=db-n1-standard-1 \
  --storage-type=SSD \
  --storage-size=10GB \
  --network=default \
  --no-assign-ip \
  --enable-google-private-path \
  --authorized-networks=0.0.0.0/0


gcloud sql databases create wordpress \
  --instance=wordpress-db \
  --charset=utf8 \
  --collation=utf8_general_ci

PROJECT_ID=$(gcloud config get-value project)

cat > cp_disk.sh <<'EOF_CP'
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy

echo $REGION
echo $PROJECT_ID
export SQL_CONNECTION=$PROJECT_ID:$REGION:wordpress-db

./cloud_sql_proxy -instances=$SQL_CONNECTION=tcp:3306 &
EOF_CP


gcloud compute scp cp_disk.sh wordpress-proxy:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh wordpress-proxy --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/cp_disk.sh"

