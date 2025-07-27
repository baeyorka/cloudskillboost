
gcloud auth list

export CLOUD_SQL_INSTANCE=postgres-orders
gcloud sql instances describe $CLOUD_SQL_INSTANCE


export UTCP=$(date -u +"%H:%M")

echo $UTCP

gcloud sql instances patch $CLOUD_SQL_INSTANCE \
    --backup-start-time=$UTCP


gcloud sql instances describe $CLOUD_SQL_INSTANCE --format 'value(settings.backupConfiguration)'

gcloud sql instances patch $CLOUD_SQL_INSTANCE \
--enable-point-in-time-recovery \
--retained-transaction-log-days=1
