

gcloud auth list

read -e -p $'\033[1;33mEnter the REGION1: \033[0m' REGION1

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$DEVSHELL_PROJECT_ID

cat > cp1_disk.sh <<EOF_CP
ls /training

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

source /training/project_env.sh

cd ~/training-data-analyst/courses/streaming/process/sandiego

sed -i 's/\\\$REGION/'"$REGION1"'/g' run_oncloud.sh

./run_oncloud.sh $DEVSHELL_PROJECT_ID \$BUCKET CurrentConditions --bigtable
EOF_CP

export ZONE=$(gcloud compute instances list training-vm --format='value(zone)')

gcloud compute scp cp1_disk.sh training-vm:/tmp --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet

gcloud compute ssh training-vm --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet --command="bash /tmp/cp1_disk.sh"

echo
echo -e "\033[1;33mGo to dataflow / jobs\033[0m \033[1;34mhttps://console.cloud.google.com/dataflow/jobs?referrer=search&inv=1&invt=AbxgKw&project=$DEVSHELL_PROJECT_ID\033[0m"
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

# cbt deletetable current_conditions

# echo "Y" | gcloud bigtable instances delete sandiego

echo
echo -e "\033[1;33mDelete the Bigtable\033[0m \033[1;34mvhttps://console.cloud.google.com/bigtable/instances/sandiego/overview?inv=1&invt=AbxgWA&project=$DEVSHELL_PROJECT_ID\033[0m"
echo

