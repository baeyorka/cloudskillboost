

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)


gcloud auth list

gcloud services enable translate.googleapis.com --project=$DEVSHELL_PROJECT_ID

gcloud iam service-accounts create apigee-proxy \
  --display-name "Apigee Proxy Service"

gcloud iam service-accounts list --project=$DEVSHELL_PROJECT_ID

echo $DEVSHELL_PROJECT_ID

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member="serviceAccount:apigee-proxy@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"


cat > translate-product.json <<EOF_CP
{
  "name": "translate-product",
  "displayName": "translate-product",
  "approvalType": "auto",
  "attributes": [
    {
      "name": "access",
      "value": "public"
    },
    {
      "name": "full-access",
      "value": "yes"
    }
  ],
  "description": "subscribe to techcps",
  "environments": [
    "eval"
  ],
  "operationGroup": {
    "operationConfigs": [
      {
        "apiSource": "translate-v1",
        "operations": [
          {
            "resource": "/",
            "methods": [
              "GET",
              "POST"
            ]
          }
        ],
        "quota": {
          "limit": "10",
          "interval": "1",
          "timeUnit": "minute"
        }
      }
    ],
    "operationConfigType": "proxy"
  }
}
EOF_CP

curl -X POST "https://apigee.googleapis.com/v1/organizations/$DEVSHELL_PROJECT_ID/apiproducts" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d @translate-product.json


curl -X POST "https://apigee.googleapis.com/v1/organizations/$DEVSHELL_PROJECT_ID/developers" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Joe",
    "lastName": "Developer",
    "userName": "joe",  
    "email": "joe@example.com"
  }'  




export INSTANCE_NAME=eval-instance; export ENV_NAME=eval; export PREV_INSTANCE_STATE=; echo "waiting for runtime instance ${INSTANCE_NAME} to be active"; while : ; do export INSTANCE_STATE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}" | jq "select(.state != null) | .state" --raw-output); [[ "${INSTANCE_STATE}" == "${PREV_INSTANCE_STATE}" ]] || (echo; echo "INSTANCE_STATE=${INSTANCE_STATE}"); export PREV_INSTANCE_STATE=${INSTANCE_STATE}; [[ "${INSTANCE_STATE}" != "ACTIVE" ]] || break; echo -n "."; sleep 5; done; echo; echo "instance created, waiting for environment ${ENV_NAME} to be attached to instance"; while : ; do export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | jq "select(.attachments != null) | .attachments[] | select(.environment == \"${ENV_NAME}\") | .environment" --join-output); [[ "${ATTACHMENT_DONE}" != "${ENV_NAME}" ]] || break; echo -n "."; sleep 5; done; echo "***ORG IS READY TO USE***";

echo ""

echo "${YELLOW}${BOLD}Go to this link to create an Apigee proxy[https://console.cloud.google.com/apigee/proxy-create?project=$DEVSHELL_PROJECT_ID]${RESET}"

echo ""

echo "${YELLOW}${BOLD}https://translation.googleapis.com/language/translate/v2${RESET}"

echo ""

echo "${YELLOW}${BOLD}apigee-proxy@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com${RESET}"

echo ""


