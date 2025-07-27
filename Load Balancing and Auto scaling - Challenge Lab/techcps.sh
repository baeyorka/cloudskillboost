


# Set text styles
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the REGION2: ${RESET}" REGION2
read -p "${YELLOW}${BOLD}Enter the ZONE3: ${RESET}" ZONE3

# Export variables after collecting input
export REGION2 ZONE3

gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=(gcloud config get-value project)


cat > startup-script.sh <<EOF_CP
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
EOF_CP


gcloud compute instance-templates create primecalc --project="$DEVSHELL_PROJECT_ID" --machine-type=e2-medium --tags http-health-check --metadata-from-file startup-script=startup-script.sh --no-address

gcloud compute health-checks create tcp http-health-check --project="$DEVSHELL_PROJECT_ID" --port=80 --unhealthy-threshold=3 --healthy-threshold=2

gcloud compute instances create stress-test-vm --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE3" --machine-type=e2-standard-2


export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

ZONE=$(gcloud compute zones list --filter="region:($REGION)" --format="value(name)" | shuf -n 1)

gcloud beta compute instance-groups managed create "$REGION-mig" \
    --project="$DEVSHELL_PROJECT_ID" \
    --base-instance-name="$REGION-mig" \
    --template="projects/$DEVSHELL_PROJECT_ID/global/instanceTemplates/primecalc" \
    --size=1 \
    --zones="$ZONE" \
    --health-check="projects/$DEVSHELL_PROJECT_ID/global/healthChecks/http-health-check" \
    --initial-delay=60 \
    --no-force-update-on-repair \
    --standby-policy-mode=manual \
    --list-managed-instances-results=pageless \
    --target-distribution-shape=EVEN \
    --instance-redistribution-type=proactive \
    --default-action-on-vm-failure=repair

gcloud beta compute instance-groups managed set-autoscaling "$REGION-mig" \
    --project="$DEVSHELL_PROJECT_ID" \
    --region="$REGION" \
    --cpu-utilization-predictive-method=none \
    --mode=on \
    --min-num-replicas=1 \
    --max-num-replicas=2 \
    --target-cpu-utilization=0.8 \
    --cool-down-period=60


#!/bin/bash

ZONE=$(gcloud compute zones list --filter="region=$REGION2" --format="value(name)" | head -n1)

if [ -z "$ZONE" ]; then
    echo "Error: Available zones not found in $REGION2"
    exit 1
fi

echo "Using Zone: $ZONE"

gcloud beta compute instance-groups managed create "$REGION2-mig" \
    --project="$DEVSHELL_PROJECT_ID" \
    --base-instance-name="$REGION2-mig" \
    --template="projects/$DEVSHELL_PROJECT_ID/global/instanceTemplates/primecalc" \
    --size=1 \
    --zones="$ZONE" \
    --health-check="projects/$DEVSHELL_PROJECT_ID/global/healthChecks/http-health-check" \
    --initial-delay=60 \
    --no-force-update-on-repair \
    --standby-policy-mode=manual \
    --list-managed-instances-results=pageless \
    --target-distribution-shape=EVEN \
    --instance-redistribution-type=proactive \
    --default-action-on-vm-failure=repair


gcloud beta compute instance-groups managed set-autoscaling "$REGION2-mig" \
    --project="$DEVSHELL_PROJECT_ID" \
    --region="$REGION2" \
    --cpu-utilization-predictive-method=none \
    --mode=on \
    --min-num-replicas=1 \
    --max-num-replicas=2 \
    --target-cpu-utilization=0.8 \
    --cool-down-period=60

gcloud compute firewall-rules create lb-firewall-rule --network default --target-tags http-health-check --allow=tcp:80 --source-ranges 35.191.0.0/16


token=$(gcloud auth application-default print-access-token)
project_id=$(gcloud config get-value project)

echo $token
echo $project_id
echo $REGION
echo $REGION2

# 1. Create A Security Policy
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "description": "Default security policy for: backend1",
    "name": "default-security-policy-for-backend-service-backend1",
    "rules": [
      {
        "action": "allow",
        "match": {"config": {"srcIpRanges": ["*"]}, "versionedExpr": "SRC_IPS_V1"},
        "priority": 2147483647
      },
      {
        "action": "throttle",
        "description": "Default rate limiting rule",
        "match": {"config": {"srcIpRanges": ["*"]}, "versionedExpr": "SRC_IPS_V1"},
        "priority": 2147483646,
        "rateLimitOptions": {
          "conformAction": "allow",
          "enforceOnKey": "IP",
          "exceedAction": "deny(403)",
          "rateLimitThreshold": {"count": 500, "intervalSec": 60}
        }
      }
    ]
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$project_id/global/securityPolicies"

sleep 45

# 2. Create A Backend Service
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "backends": [
      {"balancingMode": "RATE", "capacityScaler": 1, "group": "projects/'"$project_id"'/regions/'"$REGION"'/instanceGroups/'"$REGION"'-mig", "maxRatePerInstance": 50},
      {"balancingMode": "RATE", "capacityScaler": 1, "group": "projects/'"$project_id"'/regions/'"$REGION2"'/instanceGroups/'"$REGION2"'-mig", "maxRatePerInstance": 50}
    ],
    "cdnPolicy": {"cacheKeyPolicy": {"includeHost": true, "includeProtocol": true, "includeQueryString": true}, "cacheMode": "CACHE_ALL_STATIC", "clientTtl": 3600, "defaultTtl": 3600, "maxTtl": 86400, "negativeCaching": false, "serveWhileStale": 0},
    "compressionMode": "DISABLED",
    "connectionDraining": {"drainingTimeoutSec": 300},
    "enableCDN": true,
    "healthChecks": ["projects/'"$project_id"'/global/healthChecks/http-health-check"],
    "loadBalancingScheme": "EXTERNAL_MANAGED",
    "localityLbPolicy": "ROUND_ROBIN",
    "name": "backend1",
    "portName": "http",
    "protocol": "HTTP",
    "securityPolicy": "projects/'"$project_id"'/global/securityPolicies/default-security-policy-for-backend-service-backend1",
    "sessionAffinity": "NONE",
    "timeoutSec": 30
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$project_id/global/backendServices"



sleep 45

# 3. Set A Security Policy to Backend Service
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "securityPolicy": "projects/'"$project_id"'/global/securityPolicies/default-security-policy-for-backend-service-backend1"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$project_id/global/backendServices/backend1/setSecurityPolicy"


sleep 20

# 4. Create A URL Map
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "defaultService": "projects/'"$project_id"'/global/backendServices/backend1",
    "name": "techcps"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$project_id/global/urlMaps"

sleep 30

# Create A Target HTTP Proxy (IPv4)
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "name": "techcps-target-proxy",
    "urlMap": "projects/'"$project_id"'/global/urlMaps/techcps"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$project_id/global/targetHttpProxies"

sleep 20

# Create A Target HTTP Proxy (IPv6)
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "name": "techcps-target-proxy-2",
    "urlMap": "projects/'"$project_id"'/global/urlMaps/techcps"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$project_id/global/targetHttpProxies"


