
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud container clusters create cluster-1 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE

kubectl create secret generic mysql-secrets --from-literal=ROOT_PASSWORD="password"

mkdir mysql-gke
cd mysql-gke

cat > volume.yaml <<EOF_CP
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-data-disk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF_CP



cat > deployment.yaml <<EOF_CP
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          ports:
            - containerPort: 3306
          volumeMounts:
            - mountPath: "/var/lib/mysql"
              subPath: "mysql"
              name: mysql-data
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secrets
                  key: ROOT_PASSWORD
            - name: MYSQL_USER
              value: testuser
            - name: MYSQL_PASSWORD
              value: password
      volumes:
        - name: mysql-data
          persistentVolumeClaim:
            claimName: mysql-data-disk
EOF_CP



cat > service.yaml <<EOF_CP
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
EOF_CP


kubectl apply -f volume.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml


helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm install mydb bitnami/mysql

