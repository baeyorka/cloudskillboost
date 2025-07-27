

export PROJECT_ID=$(gcloud config get-value project)
export TAG_KEY_NAME="sensitivity-level"
export TAG_KEY_DESCRIPTION="Sensitivity level tagged as low, moderate, high, and unknown"


gcloud resource-manager tags keys create $TAG_KEY_NAME \
    --parent=projects/$PROJECT_ID \
    --description="$TAG_KEY_DESCRIPTION"

gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)"


export TAG_KEY_ID=$(gcloud resource-manager tags keys list --parent=projects/$PROJECT_ID --format="value(name)")

echo $TAG_KEY_ID


gcloud resource-manager tags values create low \
    --parent=$TAG_KEY_ID \
    --description="Tag value to attach to low-sensitivity data"

gcloud resource-manager tags values create moderate \
    --parent=$TAG_KEY_ID \
    --description="Tag value to attach to moderate-sensitivity data"

gcloud resource-manager tags values create high \
    --parent=$TAG_KEY_ID \
    --description="Tag value to attach to high-sensitivity data"

gcloud resource-manager tags values create unknown \
    --parent=$TAG_KEY_ID \
    --description="Tag value to attach to resources with an unknown sensitivity level"

gcloud resource-manager tags values list --parent=$TAG_KEY_ID

echo ""

echo "https://console.cloud.google.com/security/sensitive-data-protection/landing/dataProfiles/dashboard?project=$DEVSHELL_PROJECT_ID"

echo ""
