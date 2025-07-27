


gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export my_region=$REGION
export my_cluster=autopilot-cluster-1

gcloud container clusters create-auto $my_cluster --region $my_region

gcloud container clusters get-credentials $my_cluster --region $my_region


kubectl create deployment --image nginx nginx-1

kubectl get pods

sleep 45

kubectl get pods

export my_nginx_pod=$(kubectl get pods --selector=app=nginx-1 --no-headers -o custom-columns=":metadata.name")

cat > test.html <<EOF_CP
<header><title>This is title</title></header>
Hello world
EOF_CP

kubectl cp ~/test.html $my_nginx_pod:/usr/share/nginx/html/test.html

kubectl get services

kubectl expose pod $my_nginx_pod --port 80 --type LoadBalancer


git clone https://github.com/GoogleCloudPlatform/training-data-analyst


ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s


cd ~/ak8s/GKE_Shell/


kubectl apply -f ./new-nginx-pod.yaml


kubectl apply -f ./new-nginx-pod.yaml

