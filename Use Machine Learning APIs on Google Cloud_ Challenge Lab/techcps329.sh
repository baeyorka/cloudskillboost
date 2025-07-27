


# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the LANGUAGE: ${RESET}" LANGUAGE
read -p "${YELLOW}${BOLD}Enter the LOCAL: ${RESET}" LOCAL
read -p "${YELLOW}${BOLD}Enter the BIGQUERY_ROLE: ${RESET}" BIGQUERY_ROLE
read -p "${YELLOW}${BOLD}Enter the CLOUD_STORAGE_ROLE: ${RESET}" CLOUD_STORAGE_ROLE

# Export variables after collecting input
export LANGUAGE LOCAL BIGQUERY_ROLE CLOUD_STORAGE_ROLE


gcloud auth list

export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud iam service-accounts create sample-sa

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$BIGQUERY_ROLE

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$CLOUD_STORAGE_ROLE

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=roles/serviceusage.serviceUsageConsumer

sleep 150

gcloud iam service-accounts keys create sample-sa-key.json --iam-account sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=${PWD}/sample-sa-key.json

wget https://raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Use%20Machine%20Learning%20APIs%20on%20Google%20Cloud%3A%20Challenge%20Lab/analyze-images-v2.py

sed -i "s/'en'/'${LOCAL}'/g" analyze-images-v2.py

python3 analyze-images-v2.py

python3 analyze-images-v2.py $DEVSHELL_PROJECT_ID $DEVSHELL_PROJECT_ID

bq query --use_legacy_sql=false "SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"


