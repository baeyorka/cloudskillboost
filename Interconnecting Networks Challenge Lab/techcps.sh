

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud services enable networkmanagement.googleapis.com osconfig.googleapis.com

gcloud compute networks create hub-vpc --subnet-mode=custom && gcloud compute networks subnets create hub-subnet --region=$REGION --network=hub-vpc --range=10.0.0.0/24

gcloud compute instances create hub-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=hub-subnet --metadata=startup-script=sudo\ apt-get\ install\ apache2\ -y,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=hub-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250212,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any

gcloud compute resource-policies create snapshot-schedule default-schedule-1 --project=$DEVSHELL_PROJECT_ID --region=$REGION --max-retention-days=14 --on-source-disk-delete=keep-auto-snapshots --daily-schedule --start-time=06:00

gcloud compute disks add-resource-policies hub-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --resource-policies=projects/$DEVSHELL_PROJECT_ID/regions/$REGION/resourcePolicies/default-schedule-1

gcloud compute firewall-rules create hub-firewall1 --network=hub-vpc --allow=icmp --source-ranges=0.0.0.0/0 && gcloud compute firewall-rules create hub-firewall2 --network=hub-vpc --allow=tcp:22 --source-ranges=35.235.240.0/20

gcloud compute instance-groups unmanaged create hub-group --project=$DEVSHELL_PROJECT_ID --zone=$ZONE && gcloud compute instance-groups unmanaged add-instances hub-group --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --instances=hub-vm

gcloud compute networks subnets create pscsubnet --region=$REGION --network=hub-vpc --range=10.1.0.0/24

gcloud services enable networkmanagement.googleapis.com osconfig.googleapis.com

gcloud beta network-management connectivity-tests create pscservice --project=$DEVSHELL_PROJECT_ID --destination-ip-address=192.0.2.1 --destination-port=80 --destination-project=$DEVSHELL_PROJECT_ID --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/hub-vm --source-ip-address=10.0.0.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/hub-vpc

gcloud compute backend-services create hub-backend-service --load-balancing-scheme=INTERNAL --protocol=TCP --region=$REGION --health-checks=hub-health-check --network=hub-vpc && gcloud compute backend-services add-backend hub-backend-service --instance-group=hub-group --instance-group-zone=$ZONE --region=$REGION 

gcloud compute forwarding-rules create hub-ilb --region=$REGION --load-balancing-scheme=internal --network=hub-vpc --subnet=hub-subnet --backend-service=hub-backend-service --ports=80

gcloud compute service-attachments create pscservice --region=$REGION --producer-forwarding-rule=hub-ilb --connection-preference=ACCEPT_AUTOMATIC --nat-subnets=pscsubnet --description="subscribe to techcps"

gcloud compute networks create spoke1-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional --bgp-best-path-selection-mode=legacy

gcloud compute networks subnets create spoke1-subnet --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=10.1.1.0/24 --stack-type=IPV4_ONLY --network=spoke1-vpc && sleep 15

gcloud compute instances create spoke1-vm --zone=$ZONE --subnet=spoke1-subnet --machine-type=e2-micro --image=projects/debian-cloud/global/images/debian-12-bookworm-v20250212 --tags=http-server

gcloud compute firewall-rules create spoke1-firewall1 --network=spoke1-vpc --allow=icmp --source-ranges=0.0.0.0/0 && gcloud compute firewall-rules create spoke1-firewall2 --network=spoke1-vpc --allow=tcp:22 --source-ranges=35.235.240.0/20

gcloud compute networks peerings create hub-spoke1 --network=hub-vpc --peer-network=spoke1-vpc --auto-create-routes && gcloud compute networks peerings create spoke1-hub --network=spoke1-vpc --peer-network=hub-vpc

gcloud compute networks create spoke2-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional --bgp-best-path-selection-mode=legacy && gcloud compute networks subnets create spoke2-subnet --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=10.2.1.0/24 --stack-type=IPV4_ONLY --network=spoke2-vpc

gcloud compute firewall-rules create spoke2-firewall1 --project=$DEVSHELL_PROJECT_ID --direction=INGRESS --priority=1000 --network=spoke2-vpc --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0 && gcloud compute firewall-rules create spoke2-firewall2 --project=$DEVSHELL_PROJECT_ID --direction=INGRESS --priority=1000 --network=spoke2-vpc --action=ALLOW --rules=tcp:22 --source-ranges=35.235.240.0/20

gcloud compute instances create spoke2-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=spoke2-subnet --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=spoke2-vm,disk-resource-policy=projects/$DEVSHELL_PROJECT_ID/regions/$REGION/resourcePolicies/default-schedule-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250212,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any && printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml && gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-$ZONE --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --file=config.yaml

gcloud compute networks create spoke3-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional --bgp-best-path-selection-mode=legacy && gcloud compute networks subnets create spoke3-subnet --project=$DEVSHELL_PROJECT_ID --region=$REGION --range=10.3.1.0/24 --stack-type=IPV4_ONLY --network=spoke3-vpc

gcloud compute firewall-rules create spoke3-firewall1 --project=$DEVSHELL_PROJECT_ID --direction=INGRESS --priority=1000 --network=spoke3-vpc --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0 && gcloud compute firewall-rules create spoke3-firewall2 --project=$DEVSHELL_PROJECT_ID --direction=INGRESS --priority=1000 --network=spoke3-vpc --action=ALLOW --rules=tcp:22 --source-ranges=35.235.240.0/20

gcloud compute instances create spoke3-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=spoke3-subnet --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=spoke3-vm,disk-resource-policy=projects/$DEVSHELL_PROJECT_ID/regions/$REGION/resourcePolicies/default-schedule-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250212,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any && printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml && gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-$ZONE --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --file=config.yaml

gcloud compute vpn-gateways create hub-gateway --region=$REGION --network=hub-vpc && gcloud compute vpn-gateways create spoke2-gateway --region=$REGION --network=spoke2-vpc

gcloud compute vpn-gateways create spoke3-gateway --region=$REGION --network=spoke3-vpc && gcloud compute routers create hub-router --region "$REGION" --network hub-vpc --asn 65000 && gcloud compute routers create spoke2-router --region "$REGION" --network spoke2-vpc --asn 65002 && gcloud compute routers create spoke3-router --region "$REGION" --network spoke3-vpc --asn 65003

gcloud compute vpn-tunnels create tun-hub-spoke2-1 --region=$REGION --vpn-gateway=hub-gateway --interface 0 --router hub-router --peer-gcp-gateway spoke2-gateway --ike-version=2 --shared-secret=[SHARED_SECRET]

gcloud compute vpn-tunnels create tun-spoke2-hub-1 --region=$REGION --vpn-gateway=spoke2-gateway --interface 0 --router spoke2-router --peer-gcp-gateway hub-gateway --ike-version=2 --shared-secret=[SHARED_SECRET]

gcloud compute vpn-tunnels create tun-hub-spoke3-1 --region=$REGION --vpn-gateway=hub-gateway --interface 0 --router hub-router --peer-gcp-gateway spoke3-gateway --ike-version=2 --shared-secret=[SHARED_SECRET]

gcloud compute vpn-tunnels create tun-spoke3-hub-1 --region=$REGION --vpn-gateway=spoke3-gateway --interface 0 --router spoke3-router --peer-gcp-gateway hub-gateway --ike-version=2 --shared-secret=[SHARED_SECRET]

gcloud network-connectivity hubs create hub-23 && gcloud network-connectivity spokes linked-vpn-tunnels create hubspoke2 --region=$REGION --hub=hub-23 --vpn-tunnels=tun-hub-spoke2-1 --site-to-site-data-transfer && gcloud network-connectivity spokes linked-vpn-tunnels create hubspoke3 --region=$REGION --hub=hub-23 --vpn-tunnels=tun-hub-spoke3-1 --site-to-site-data-transfer

gcloud compute firewall-rules delete $(gcloud compute firewall-rules list --filter="network:default" --format="value(name)") --quiet && gcloud compute networks delete default --quiet

gcloud compute networks create spoke4-vpc --project=$DEVSHELL_PROJECT_ID --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional --bgp-best-path-selection-mode=legacy && gcloud compute networks subnets create spoke4-subnet --project=$DEVSHELL_PROJECT_ID --range=10.4.1.0/24 --stack-type=IPV4_ONLY --network=spoke4-vpc --region=$REGION

gcloud compute firewall-rules create spoke4-firewall --network=spoke4-vpc --allow=tcp:22 --source-ranges=35.235.240.0/20

gcloud compute instances create spoke4-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=spoke4-subnet --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=spoke4-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250212,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any && printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml && gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-$ZONE --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --file=config.yaml

gcloud beta network-management connectivity-tests create test-spoke1-hub --destination-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/hub-vm --destination-network=projects/$DEVSHELL_PROJECT_ID/global/networks/hub-vpc --destination-port=80 --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke1-vm --source-ip-address=10.1.1.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke1-vpc --project=$DEVSHELL_PROJECT_ID && gcloud beta network-management connectivity-tests create test-spoke2-hub --destination-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/hub-vm --destination-network=projects/$DEVSHELL_PROJECT_ID/global/networks/hub-vpc --destination-port=80 --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke2-vm --source-ip-address=10.1.1.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke1-vpc --project=$DEVSHELL_PROJECT_ID && gcloud beta network-management connectivity-tests create test-spoke3-hub --destination-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/hub-vm --destination-network=projects/$DEVSHELL_PROJECT_ID/global/networks/hub-vpc --destination-port=80 --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke2-vm --source-ip-address=10.1.1.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke1-vpc --project=$DEVSHELL_PROJECT_ID && gcloud beta network-management connectivity-tests create test-spoke2-spoke3 --destination-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke3-vm --destination-network=projects/$DEVSHELL_PROJECT_ID/global/networks/hub-vpc --destination-port=80 --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke1-vm --source-ip-address=10.1.1.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke1-vpc --project=$DEVSHELL_PROJECT_ID && gcloud beta network-management connectivity-tests create test-spoke4-hub --destination-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke4-vm --destination-ip-address=10.4.1.2 --destination-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke4-vpc --destination-port=80 --protocol=TCP --round-trip --source-instance=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/spoke4-vm --source-ip-address=10.4.1.2 --source-network=projects/$DEVSHELL_PROJECT_ID/global/networks/spoke4-vpc --project=$DEVSHELL_PROJECT_ID

gcloud compute health-checks create tcp hub-health-check --port=80 --global && gcloud compute backend-services create hub-backend-service --load-balancing-scheme=INTERNAL --protocol=TCP --region=$REGION --health-checks=hub-health-check --network=hub-vpc && gcloud compute forwarding-rules create hub-ilb --region=$REGION --load-balancing-scheme=INTERNAL --network=hub-vpc --subnet=pscsubnet --ip-protocol=TCP --ports=80 --backend-service=hub-backend-service --allow-global-access

gcloud compute networks subnets create psc-subnet-psc --region=$REGION --network=hub-vpc --range=10.10.10.0/24 --purpose=PRIVATE_SERVICE_CONNECT && gcloud compute service-attachments create pscservice --region=$REGION --producer-forwarding-rule=hub-ilb --nat-subnets=psc-subnet-psc --connection-preference=ACCEPT_AUTOMATIC

gcloud compute addresses create psc-endpoint-ip --region=$REGION --subnet=spoke4-subnet --addresses=10.4.1.10 && gcloud compute forwarding-rules create pscendpoint --region=$REGION --network=spoke4-vpc --subnet=spoke4-subnet --target-service-attachment="https://www.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION/serviceAttachments/pscservice" --address=psc-endpoint-ip


