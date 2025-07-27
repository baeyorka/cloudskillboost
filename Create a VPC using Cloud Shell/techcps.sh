
gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud compute networks create labnet --subnet-mode=custom

gcloud compute networks subnets create labnet-sub \
   --network labnet \
   --region $REGION \
   --range 10.0.0.0/28

   
