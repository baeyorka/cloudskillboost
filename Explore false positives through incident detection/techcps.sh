

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the STUDENT2: ${RESET}" STUDENT2

# Export variables after collecting input
export STUDENT2

export SERVICE_ACCOUNT="test-account"
export PROJECT_ID=$(gcloud config get-value project)

gcloud iam service-accounts create $SERVICE_ACCOUNT \
  --description="subscribe to techcps" \
  --display-name="Test Account"

echo "Service account '$SERVICE_ACCOUNT' created successfully."

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"


gcloud iam service-accounts list

gcloud iam service-accounts keys create test-account.json \
    --iam-account=${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

ls

export PROJECT_ID=$(gcloud info --format='value(config.project)')
export SA_NAME="test-account@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud auth activate-service-account ${SA_NAME} --key-file=test-account.json

gcloud auth list

gcloud projects add-iam-policy-binding $PROJECT_ID --member user:$STUDENT2 --role roles/editor

