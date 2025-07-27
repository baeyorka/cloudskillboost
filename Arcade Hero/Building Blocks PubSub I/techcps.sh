

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the TOPIC_NAME: ${RESET}" TOPIC_NAME
read -p "${YELLOW}${BOLD}Enter the SUBS_NAME: ${RESET}" SUBS_NAME

# Export variables after collecting input
export TOPIC_NAME SUBS_NAME

gcloud auth list

gcloud pubsub topics create $TOPIC_NAME

gcloud  pubsub subscriptions create --topic $TOPIC_NAME $SUBS_NAME

