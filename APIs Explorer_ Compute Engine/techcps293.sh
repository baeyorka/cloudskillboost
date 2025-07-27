

gcloud auth list

gcloud services enable compute.googleapis.com

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances create instance-1 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=n1-standard-1 --image-family=debian-11 --image-project=debian-cloud --boot-disk-device-name=instance-1 --boot-disk-type=pd-standard

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


gcloud compute instances delete instance-1 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

