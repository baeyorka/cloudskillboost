

gcloud --version

gcloud auth login

export PROJECT_ID=$(gcloud config get-value core/project)

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo $ZONE
echo $REGION

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

gcloud compute instances create lab-1 --zone $ZONE --machine-type=e2-standard-2

gcloud config list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo ""

echo -e "\033[1;33mThis is your current zone: $ZONE.\033[0m" "You could select a different zone from those listed below:"

echo ""

gcloud compute zones list --filter="region:($REGION)" --format="value(name)" | while read -r zone; do
  echo -e "\033[1;33m$zone\033[0m"
done

read -e -p $'\033[1;33mEnter the ZONE: \033[0m' ZONE

gcloud config set compute/zone $ZONE

echo -e "\033[1;33mNow this is your new zone: $ZONE.\033[0m"

gcloud config list

cat ~/.config/gcloud/configurations/config_default

gcloud init --no-launch-browser

echo ""

echo -e "\033[1;33mOpen this link.\033[0m \033[1;34mhttps://console.cloud.google.com/iam-admin/iam?invt=AbutQA&project=$PROJECT_ID\033[0m"

echo ""

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


gcloud iam roles list | grep "name:"

gcloud iam roles describe roles/compute.instanceAdmin

read -e -p $'\033[1;33mEnter the USER2: \033[0m' USER2

read -e -p $'\033[1;33mEnter the PROJECT_ID2: \033[0m' PROJECT_ID2

gcloud config configurations activate user2

echo "export PROJECTID2=$PROJECT_ID2" >> ~/.bashrc
. ~/.bashrc

gcloud config configurations activate default

sudo yum -y install epel-release
sudo yum -y install jq

echo "export USERID2=$USER2" >> ~/.bashrc

. ~/.bashrc
gcloud projects add-iam-policy-binding $PROJECT_ID2 --member user:$USER2 --role=roles/viewer

gcloud config configurations activate user2

gcloud compute instances list

gcloud config set project $PROJECT_ID2

gcloud compute instances create lab-2 --zone $ZONE --machine-type=e2-standard-2

gcloud config configurations activate default

gcloud iam roles create devops --project $PROJECTID2 --permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"

gcloud projects add-iam-policy-binding $PROJECT_ID2 --member user:$USER2 --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID2 --member user:$USER2 --role=projects/$PROJECT_ID2/roles/devops

gcloud config configurations activate user2

gcloud compute instances list

gcloud config configurations activate default

gcloud config set project $PROJECT_ID2

gcloud iam service-accounts create devops --display-name devops

gcloud iam service-accounts list  --filter "displayName=devops"

SA=$(gcloud iam service-accounts list --format="value(email)" --filter "displayName=devops")

gcloud projects add-iam-policy-binding $PROJECT_ID2 --member serviceAccount:$SA --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID2 --member serviceAccount:$SA --role=roles/compute.instanceAdmin

gcloud compute instances create lab-3 --zone $ZONE --machine-type=e2-standard-2 --service-account $SA --scopes "https://www.googleapis.com/auth/compute"


