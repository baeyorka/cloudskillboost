

gsutil cp gs://spls/gsp774/archive.zip .

unzip archive.zip

export DATA_FILE=PS_20174392719_1491204439457_log.csv

export PROJECT_ID=$(gcloud config get-value project)

bq mk --dataset $PROJECT_ID:finance

gsutil mb gs://$PROJECT_ID

gsutil cp $DATA_FILE gs://$PROJECT_ID


bq load --autodetect --source_format=CSV --max_bad_records=100000 finance.fraud_data gs://$PROJECT_ID/$DATA_FILE


bq query --use_legacy_sql=false \
'SELECT type, isFraud, COUNT(*) as cnt
 FROM `finance.fraud_data`
 GROUP BY isFraud, type
 ORDER BY type'

bq query --use_legacy_sql=false '
SELECT isFraud, COUNT(*) as cnt
FROM `finance.fraud_data`
WHERE type IN ("CASH_OUT", "TRANSFER")
GROUP BY isFraud'


bq query --nouse_legacy_sql \
'SELECT *
 FROM `finance.fraud_data`
 ORDER BY amount DESC
 LIMIT 10'

