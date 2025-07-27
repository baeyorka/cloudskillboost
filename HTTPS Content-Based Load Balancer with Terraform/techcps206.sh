

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the group1_region: ${RESET}" group1_region
read -p "${YELLOW}${BOLD}Enter the group2_region: ${RESET}" group2_region
read -p "${YELLOW}${BOLD}Enter the group3_region: ${RESET}" group3_region

git clone https://github.com/terraform-google-modules/terraform-google-lb-http.git

cd ~/terraform-google-lb-http/examples/multi-backend-multi-mig-bucket-https-lb

export GOOGLE_PROJECT=$(gcloud config get-value project)

rm -rf main.tf

wget https://raw.githubusercontent.com/techcps/Google-Cloud-Skills-Boost/master/HTTPS%20Content-Based%20Load%20Balancer%20with%20Terraform/main.tf


cat > variables.tf <<EOF_CP
variable "group1_region" {
  default = "$group1_region"
}

variable "group2_region" {
  default = "$group2_region"
}

variable "group3_region" {
  default = "$group3_region"
}

variable "network_name" {
  default = "ml-bk-ml-mig-bkt-s-lb"
}

variable "project" {
  type = string
}
EOF_CP

terraform init 

echo "$GOOGLE_PROJECT" | terraform plan

echo "$GOOGLE_PROJECT" | terraform apply --auto-approve


EXTERNAL_IP=$(terraform output | grep load-balancer-ip | cut -d = -f2 | xargs echo -n)
echo http://${EXTERNAL_IP}
