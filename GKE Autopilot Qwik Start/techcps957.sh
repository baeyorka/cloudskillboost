
gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region "$REGION"

gcloud container clusters get-credentials dev-cluster --region $REGION

cd ~/voting-demo/v2

skaffold run --default-repo=gcr.io/$PROJECT_ID/voting-app --tail

kubectl get svc web-external --output=json | jq -r .status.loadBalancer.ingress[0].ip


web_external_ip=$(kubectl get svc web-external --output=json | jq -r .status.loadBalancer.ingress[0].ip)

echo
echo -e "\033[1;33mhttp://$web_external_ip\033[0m"
echo
echo -e "\033[1;33mhttp://$web_external_ip/results\033[0m"
echo

while true; do
    echo -ne "\e[1;93mDo you Want to proceed? (Y/n): \e[0m"
    read confirm
    case "$confirm" in
        [Yy]) 
            echo -e "\e[34mRunning the command...\e[0m"
            break
            ;;
        [Nn]|"") 
            echo "Operation canceled."
            break
            ;;
        *) 
            echo -e "\e[31mInvalid input. Please enter Y or N.\e[0m" 
            ;;
    esac
done


skaffold delete

