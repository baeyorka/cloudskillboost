

gcloud auth list

gcloud alpha services api-keys create --display-name="techcps"

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter="displayName=techcps")

export API_KEY=$(gcloud alpha services api-keys get-key-string "$KEY_NAME" --format="value(keyString)")

gcloud services enable language.googleapis.com
gcloud services enable apikeys.googleapis.com

# Save API_KEY export to a file
echo "export API_KEY='${API_KEY}'" > /tmp/cp_disk.sh

cat > cp_env.sh <<EOF
KEY_NAME=\$(gcloud alpha services api-keys list --format="value(name)" --filter="displayName=techcps")
export API_KEY=\$(gcloud alpha services api-keys get-key-string "\$KEY_NAME" --format="value(keyString)")
EOF


echo "export API_KEY='${API_KEY}'" > /tmp/cp_env.sh

cat > cp_disk.sh <<'EOF_CP'
cat > request.json <<EOF
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus, but keeps the sea salt, olive oil, pimentón and boiled potatoes."
  }
}
EOF

# Load the API key
source /tmp/cp_env.sh

curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json


curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json

gsutil cat gs://spls/gsp063/bbc_dataset/entertainment/001.txt

bq --location=US mk --dataset news_classification_dataset

bq mk --table news_classification_dataset.article_data article_text:STRING,category:STRING,confidence:FLOAT
EOF_CP

ZONE=$(gcloud compute instances list --project="$DEVSHELL_PROJECT_ID" --filter="name=('linux-instance')" --format="value(zone)")

gcloud compute scp cp_env.sh cp_disk.sh linux-instance:/tmp --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet

gcloud compute ssh linux-instance --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet --command="bash /tmp/cp_disk.sh"

