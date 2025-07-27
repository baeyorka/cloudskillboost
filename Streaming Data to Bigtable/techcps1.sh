

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud config set compute/zone "$ZONE"

gcloud config set compute/region "$REGION"

# gcloud bigtable instances create sandiego --display-name="San Diego Traffic Sensors" --cluster-storage-type=SSD --cluster-config=id=sandiego-traffic-sensors-c1,zone=$ZONE,nodes=1

echo
echo -e "\033[1;33mCreate a Bigtable\033[0m \033[1;34mvhttps://console.cloud.google.com/bigtable/create-instance?inv=1&invt=AbxgKw&project=$DEVSHELL_PROJECT_ID\033[0m"
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


echo project = `gcloud config get-value project` \
    >> ~/.cbtrc

echo instance = sandiego \
    >> ~/.cbtrc

cat ~/.cbtrc

cbt createtable current_conditions \
    families="lane"

cat > cp_disk.sh <<'EOF_CP'

ls /training

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

source /training/project_env.sh

/training/sensor_magic.sh

EOF_CP

export ZONE=$(gcloud compute instances list training-vm --format 'csv[no-heading](zone)')

gcloud compute scp cp_disk.sh training-vm:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh training-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/cp_disk.sh"


