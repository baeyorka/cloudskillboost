
# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the USER: ${RESET}" USER

# Export variables after collecting input
export USER

gcloud auth list

gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
    --member="user:$USER" \
    --role="roles/storage.objectViewer"
