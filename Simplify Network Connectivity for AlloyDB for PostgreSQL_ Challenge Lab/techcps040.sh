

# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the CLUSTER_ID: ${RESET}" CLUSTER_ID
read -p "${YELLOW}${BOLD}Enter the PASSWORD: ${RESET}" PASSWORD
read -p "${YELLOW}${BOLD}Enter the INSTANCE_ID: ${RESET}" INSTANCE_ID

# Export variables after collecting input
export CLUSTER_ID PASSWORD INSTANCE_ID


gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud compute addresses create psa-range \
  --global \
  --purpose=VPC_PEERING \
  --prefix-length=24 \
  --addresses=10.8.12.0 \
  --network=cloud-vpc

gcloud services vpc-peerings connect \
  --service=servicenetworking.googleapis.com \
  --ranges=psa-range \
  --network=cloud-vpc

gcloud compute networks peerings list --network=cloud-vpc

gcloud compute networks peerings update servicenetworking-googleapis-com \
  --export-custom-routes \
  --import-custom-routes \
  --network=cloud-vpc


gcloud alloydb clusters create $CLUSTER_ID \
  --project=$DEVSHELL_PROJECT_ID \
  --region=$REGION \
  --network=cloud-vpc \
  --password=$PASSWORD \
  --allocated-ip-range-name=psa-range

gcloud alloydb instances create $INSTANCE_ID \
  --project=$DEVSHELL_PROJECT_ID \
  --region=$REGION \
  --cluster=$CLUSTER_ID \
  --instance-type=PRIMARY \
  --cpu-count=2


# Task 4. Establish a HA VPN connection

gcloud beta compute vpn-gateways create cloud-vpc-vpn-gw1 --region=$REGION --network cloud-vpc && gcloud beta compute vpn-gateways describe cloud-vpc-vpn-gw1 --region=$REGION

gcloud beta compute vpn-gateways create on-prem-vpn-gw1 --region=$REGION --network  on-prem-vpc && gcloud beta compute vpn-gateways describe  on-prem-vpn-gw1 --region=$REGION

gcloud compute routers create cloud-vpc-router1 --region=$REGION --network cloud-vpc --asn 65001 && gcloud compute routers create  on-prem-vpc-router1 --region=$REGION --network on-prem-vpc --asn 65002


gcloud beta compute vpn-tunnels create cloud-vpc-tunnel0 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region=$REGION \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router cloud-vpc-router1 \
    --vpn-gateway cloud-vpc-vpn-gw1 \
    --interface 0


gcloud beta compute vpn-tunnels create cloud-vpc-tunnel1 \
    --peer-gcp-gateway  on-prem-vpn-gw1 \
    --region=$REGION \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router cloud-vpc-router1 \
    --vpn-gateway cloud-vpc-vpn-gw1 \
    --interface 1


gcloud beta compute vpn-tunnels create on-prem-vpc-tunnel0 \
    --peer-gcp-gateway cloud-vpc-vpn-gw1 \
    --region=$REGION \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-vpc-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 0

gcloud beta compute vpn-tunnels create on-prem-vpc-tunnel1 \
    --peer-gcp-gateway cloud-vpc-vpn-gw1 \
    --region=$REGION \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-vpc-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 1


gcloud compute routers add-interface cloud-vpc-router1 \
    --region=$REGION \
    --interface-name if-tunnel0-to-on-prem-vpc \
    --ip-address 169.254.0.1 \
    --mask-length 30 \
    --vpn-tunnel cloud-vpc-tunnel0

gcloud compute routers add-bgp-peer cloud-vpc-router1 \
    --region=$REGION \
    --peer-name bgp-on-prem-tunnel0 \
    --interface if-tunnel0-to-on-prem-vpc \
    --peer-ip-address 169.254.0.2 \
    --peer-asn 65002

gcloud compute routers add-interface cloud-vpc-router1 \
    --region=$REGION \
    --interface-name if-tunnel1-to-on-prem-vpc \
    --ip-address 169.254.1.1 \
    --mask-length 30 \
    --vpn-tunnel cloud-vpc-tunnel1

gcloud compute routers add-bgp-peer cloud-vpc-router1 \
    --region=$REGION \
    --peer-name bgp-on-prem-vpc-tunnel1 \
    --interface if-tunnel1-to-on-prem-vpc \
    --peer-ip-address 169.254.1.2 \
    --peer-asn 65002

gcloud compute routers add-interface  on-prem-vpc-router1 \
    --region=$REGION \
    --interface-name if-tunnel0-to-cloud-vpc \
    --ip-address 169.254.0.2 \
    --mask-length 30 \
    --vpn-tunnel  on-prem-vpc-tunnel0

gcloud compute routers add-bgp-peer  on-prem-vpc-router1 \
    --region=$REGION \
    --peer-name bgp-cloud-vpc-tunnel0 \
    --interface if-tunnel0-to-cloud-vpc \
    --peer-ip-address 169.254.0.1 \
    --peer-asn 65001

gcloud compute routers add-interface   on-prem-vpc-router1 \
    --region=$REGION \
    --interface-name if-tunnel1-to-cloud-vpc \
    --ip-address 169.254.1.2 \
    --mask-length 30 \
    --vpn-tunnel  on-prem-vpc-tunnel1

gcloud compute routers add-bgp-peer   on-prem-vpc-router1 \
    --region=$REGION \
    --peer-name bgp-cloud-vpc-tunnel1 \
    --interface if-tunnel1-to-cloud-vpc \
    --peer-ip-address 169.254.1.1 \
    --peer-asn 65001

gcloud compute firewall-rules create vpc-demo-allow-subnets-from-on-prem \
    --network cloud-vpc \
    --allow tcp,udp,icmp \
    --source-ranges 192.168.1.0/24

gcloud compute firewall-rules create on-prem-allow-subnets-from-vpc-demo \
    --network on-prem-vpc \
    --allow tcp,udp,icmp \
    --source-ranges 10.1.1.0/24,10.2.1.0/24

gcloud compute networks update cloud-vpc --bgp-routing-mode GLOBAL


# Task 5. Verify AlloyDB connectivity across the Cloud VPN connection

gcloud config set compute/region $REGION

gcloud compute routes create alloydb-custom-route \
    --network=on-prem-vpc \
    --destination-range=10.8.12.0/24 \
    --next-hop-vpn-tunnel=on-prem-vpc-tunnel0 \
    --priority=1000

gcloud compute routes create alloydb-return-route \
    --network=cloud-vpc \
    --destination-range=10.1.1.0/24 \
    --next-hop-vpn-tunnel=cloud-vpc-tunnel0 \
    --priority=1000


IP=$(gcloud alloydb instances describe $INSTANCE_ID --region=$REGION --cluster=$CLUSTER_ID --project=$DEVSHELL_PROJECT_ID --format="value(ipAddress)")

echo ""

echo "${YELLOW}${BOLD}"psql -h $IP -U postgres -d postgres"${RESET}"

echo ""

echo "${YELLOW}${BOLD}"$PASSWORD"${RESET}"

echo ""


