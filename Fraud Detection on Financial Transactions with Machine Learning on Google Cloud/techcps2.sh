
bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL
finance.model_supervised_boosted_tree
OPTIONS(model_type="BOOSTED_TREE_CLASSIFIER", INPUT_LABEL_COLS=["isfraud"])
AS
SELECT
type, amount, oldbalanceOrig, newbalanceOrig, oldbalanceDest, newbalanceDest, isFraud
FROM finance.fraud_data_model'


bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE finance.table_perf AS
SELECT "Initial_reg" as model_name, *
FROM ML.EVALUATE(MODEL `finance.model_supervised_initial`, (
  SELECT *
  FROM `finance.fraud_data_model` ))'


bq query --use_legacy_sql=false '
INSERT INTO `finance.table_perf`
SELECT "improved_reg" as model_name, *
FROM ML.EVALUATE(MODEL `finance.model_supervised_boosted_tree`, (
  SELECT *
  FROM `finance.fraud_data_model` 
))'


bq query --use_legacy_sql=false '
SELECT id, label as predicted, isFraud as actual
FROM
  ML.PREDICT(MODEL `finance.model_supervised_initial`,
  (
   SELECT  *
   FROM  `finance.fraud_data_test`
  )
 ), unnest(predicted_isfraud_probs) as p
WHERE p.label = 1 and p.prob > 0.5
'
