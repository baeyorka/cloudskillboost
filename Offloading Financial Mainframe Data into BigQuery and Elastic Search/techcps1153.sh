


gcloud services enable dataflow.googleapis.com

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)

gsutil mb gs://$GOOGLE_CLOUD_PROJECT

gsutil cp -r gs://spls/gsp1153/* gs://$GOOGLE_CLOUD_PROJECT

bq --location=us mk --dataset mainframe_import

gsutil cp gs://$GOOGLE_CLOUD_PROJECT/schema_*.json .


bq load --source_format=NEWLINE_DELIMITED_JSON mainframe_import.accounts gs://$GOOGLE_CLOUD_PROJECT/accounts.json schema_accounts.json

bq load --source_format=NEWLINE_DELIMITED_JSON mainframe_import.transactions gs://$GOOGLE_CLOUD_PROJECT/transactions.json schema_transactions.json

bq query --use_legacy_sql=false \
"CREATE VIEW \`$GOOGLE_CLOUD_PROJECT.mainframe_import.account_transactions\` AS
SELECT t.*, a.* EXCEPT (id)
FROM \`$GOOGLE_CLOUD_PROJECT.mainframe_import.accounts\` AS a
JOIN \`$GOOGLE_CLOUD_PROJECT.mainframe_import.transactions\` AS t
ON a.id = t.account_id;"


bq query --use_legacy_sql=false \
"SELECT * FROM \`mainframe_import.transactions\` LIMIT 100"

bq query --use_legacy_sql=false \
"SELECT DISTINCT(occupation), COUNT(occupation)
FROM \`mainframe_import.accounts\`
GROUP BY occupation"

bq query --use_legacy_sql=false \
"SELECT *
FROM \`mainframe_import.accounts\`
WHERE salary_range = '110,000+'
ORDER BY name"


bq query --use_legacy_sql=false \
"
SELECT * FROM \`mainframe_import.accounts\` WHERE salary_range = '110,000+' ORDER BY name
"


gcloud services enable dataflow.googleapis.com

gcloud services enable bigquery.googleapis.com

# Cloud id and API Key's 1
# export CONNECTION_URL=46063b660da74fbfb60754d5aaa53699:dXMtZWFzdDQuZ2NwLmVsYXN0aWMtY2xvdWQuY29tJGY5NGQ3OTk2ZjRmZDQxMGI5N2Y0MTRmZWNlODAyZDAzJDgzZDRhMTk5YjUyMzQ1MzlhMjI3MGJiOGY3NmUwYzEy
# export API_KEY=c2tDYWFaUUJnbDlKMm82S001YzA6Mnhpb3JROHBSWmV1dUlhTW10aTRrZw==

# Cloud id and API Key's 2
# export CONNECTION_URL=e0d8358d764c47c5a18bc152aa5ab4d9:dXMtY2VudHJhbDEuZ2NwLmNsb3VkLmVzLmlvOjQ0MyQ3YWI5YzUwZmQ2N2M0Y2Q4YjE4YzMwZTYwZWRmYWI3OCQ1ZmJhZDM5ZGIzMWU0MjY2YTE0MmQyM2MzOWY5MmIxYg== 
# export API_KEY=dElleWVaUUJubWNJRU1kSkx3bDI6RDlyQ1lTcG9TQUN5UlpTOU12X3RZUQ==

# Cloud id and API Key's 3
export CONNECTION_URL=My_deployment:dXMtZWFzdDEuZ2NwLmVsYXN0aWMtY2xvdWQuY29tJDk4YzA3MWMxMjBiOTQwNzQ5OTk4NGNjNzZhZTQ4ZWViJDZlOWI5MjMxYzIyMjQ2NDNiZjFkZGY3OTNkNTAxMDll                                                                                                     
export API_KEY=dElleWVaUUJubWNJRU1kSkx3bDI6RDlyQ1lTcG9TQUN5UlpTOU12X3RZUQ==
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

sleep 30

echo $CONNECTION_URL
echo $API_KEY
echo $REGION
echo $GOOGLE_CLOUD_PROJECT

gcloud dataflow flex-template run bqtoelastic-`date +%s` --worker-machine-type=e2-standard-2 --template-file-gcs-location gs://dataflow-templates-$REGION/latest/flex/BigQuery_to_Elasticsearch --region $REGION --num-workers 1 --parameters index=transactions,maxNumWorkers=1,query="select * from \`$GOOGLE_CLOUD_PROJECT\`.mainframe_import.account_transactions",connectionUrl=$CONNECTION_URL,apiKey=$API_KEY

echo ""

echo "https://console.cloud.google.com/dataflow/jobs?project=$DEVSHELL_PROJECT_ID"

echo ""
