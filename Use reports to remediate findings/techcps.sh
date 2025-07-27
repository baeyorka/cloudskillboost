

export BUCKET_NAME="$DEVSHELL_PROJECT_ID"

gcloud storage buckets remove-iam-policy-binding gs://$BUCKET_NAME \
    --member="allUsers" \
    --role="roles/storage.objectViewer"


gcloud storage buckets update gs://$BUCKET_NAME \
    --uniform-bucket-level-access


gcloud storage buckets describe gs://$BUCKET_NAME \
    --format="value(uniformBucketLevelAccess.enabled)"


