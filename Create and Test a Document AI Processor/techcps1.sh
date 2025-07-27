
gcloud auth list

gcloud services enable documentai.googleapis.com --project=$DEVSHELL_PROJECT_ID

export PROJECT_ID=$(gcloud config get-value project)

echo ""

echo -e "\033[1;33mCreate an "form-parser" Processor:\033[0m \033[1;34mhttps://console.cloud.google.com/ai/document-ai/processor-library?inv=1&invt=Ab2Kyg&project=$DEVSHELL_PROJECT_ID\033[0m"

echo ""

echo -e "\033[1;33mClick here to Download the form.pdf:\033[0m \033[1;34mhttps://storage.googleapis.com/cloud-training/document-ai/generic/form.pdf\033[0m"

echo ""

export ZONE=$(gcloud compute instances list document-ai-dev --format='csv[no-heading](zone)')

gcloud compute ssh --zone "$ZONE" "document-ai-dev" --project "$DEVSHELL_PROJECT_ID" --quiet

