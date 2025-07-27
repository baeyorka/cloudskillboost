
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud compute instances create sqlserver-lab --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --image-family=sql-2022-web-windows-2022 --image-project=windows-sql-cloud --machine-type=e2-medium --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=sqlserver-lab,image=projects/windows-sql-cloud/global/images/sql-2022-web-windows-2022-dc-v20240711,mode=rw,size=50,type=pd-balanced

gcloud compute reset-windows-password sqlserver-lab --zone=$ZONE --quiet

  
