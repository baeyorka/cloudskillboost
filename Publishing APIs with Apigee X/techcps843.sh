

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export INSTANCE_NAME=eval-instance; export ENV_NAME=eval; export PREV_INSTANCE_STATE=; echo "waiting for runtime instance ${INSTANCE_NAME} to be active"; while : ; do export INSTANCE_STATE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}" | jq "select(.state != null) | .state" --raw-output); [[ "${INSTANCE_STATE}" == "${PREV_INSTANCE_STATE}" ]] || (echo; echo "INSTANCE_STATE=${INSTANCE_STATE}"); export PREV_INSTANCE_STATE=${INSTANCE_STATE}; [[ "${INSTANCE_STATE}" != "ACTIVE" ]] || break; echo -n "."; sleep 5; done; echo; echo "instance created, waiting for environment ${ENV_NAME} to be attached to instance"; while : ; do export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | jq "select(.attachments != null) | .attachments[] | select(.environment == \"${ENV_NAME}\") | .environment" --join-output); [[ "${ATTACHMENT_DONE}" != "${ENV_NAME}" ]] || break; echo -n "."; sleep 5; done; echo "***ORG IS READY TO USE***";

# Create bank-fullaccess API product
cat > bank-fullaccess.json <<EOF_CP
{
  "name": "bank-fullaccess",
  "displayName": "bank (full access)",
  "approvalType": "auto",
  "attributes": [
    { "name": "access", "value": "public" },
    { "name": "full-access", "value": "yes" }
  ],
  "description": "allows full access to bank API",
  "environments": ["eval"],
  "operationGroup": {
    "operationConfigs": [
      {
        "apiSource": "bank-v1",
        "operations": [
          {
            "resource": "/**",
            "methods": ["DELETE", "GET", "PATCH", "POST", "PUT"]
          }
        ],
        "quota": {
          "limit": "5",
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
  -d @bank-fullaccess.json

# Create bank-readonly API product
cat > bank-readonly.json <<EOF_CP
{
  "name": "bank-readonly",
  "displayName": "bank (read-only)",
  "approvalType": "auto",
  "attributes": [
    { "name": "access", "value": "public" }
  ],
  "description": "allows read-only access to bank API",
  "environments": ["eval"],
  "operationGroup": {
    "operationConfigs": [
      {
        "apiSource": "bank-v1",
        "operations": [
          {
            "resource": "/**",
            "methods": ["GET"]
          }
        ],
        "quota": {}
      }
    ],
    "operationConfigType": "proxy"
  }
}
EOF_CP

curl -X POST "https://apigee.googleapis.com/v1/organizations/$DEVSHELL_PROJECT_ID/apiproducts" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d @bank-readonly.json

# Create a developer
curl -X POST "https://apigee.googleapis.com/v1/organizations/$DEVSHELL_PROJECT_ID/developers" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Joe",
    "lastName": "Developer",
    "userName": "joe",  
    "email": "joe@example.com"
  }'

# Download API spec file techcps

curl -LO raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Publishing%20APIs%20with%20Apigee%20X/simplebank-spec.yaml

# Replace <URL> placeholder with actual proxy URL techcps
export IP_ADDRESS=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/envgroups/eval-group" | jq -r '.hostnames[1]')

export URL=https://eval.${IP_ADDRESS}/bank/v1

sed -i 's|<URL>|'"$URL"'|g' simplebank-spec.yaml

cloudshell download simplebank-spec.yaml

sleep 15

echo ""

echo -e "\033[1;33mCreate an Apigee proxy:\033[0m \033[1;34mhttps://console.cloud.google.com/apigee/proxy-create?project=$DEVSHELL_PROJECT_ID\033[0m"

echo ""

echo -e "\033[1;33mBackend URL:\033[0m \033[1;34m$(gcloud run services describe simplebank-rest --platform managed --region $REGION --format='value(status.url)')\033[0m"

echo ""

echo -e "\033[1;33mCopy this service account:\033[0m \033[1;34mapigee-internal-access@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com\033[0m"

echo ""

sleep 30

curl -LO raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Publishing%20APIs%20with%20Apigee%20X/bank-v1_rev2.zip

cloudshell download bank-v1_rev2.zip


