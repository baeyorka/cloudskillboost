

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the DATASET_NAME: ${RESET}" DATASET_NAME

# Export variables after collecting input
export DATASET_NAME

gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

bq mk --location=$REGION $DATASET_NAME

