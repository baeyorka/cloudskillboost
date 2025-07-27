

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the EMAIL_ID2: ${RESET}" EMAIL_ID2


# Export variables after collecting input
export EMAIL_ID2

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="user:$EMAIL_ID2" \
    --role="roles/viewer"

gcloud services enable dialogflow.googleapis.com

