
gcloud auth list

gcloud services enable osconfig.googleapis.com

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

gcloud compute instances create my-vm-1 --project="$PROJECT_ID" --zone="$ZONE" --machine-type=e2-standard-2 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account="$PROJECT_NUMBER-compute@developer.gserviceaccount.com" --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=my-vm-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20250606,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any


sleep 60

cat > techcps.sh <<'EOF_CP'

sudo apt update

curl -LO https://github.com/eosio/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb

sudo apt install -y ./eosio_2.1.0-1-ubuntu-20.04_amd64.deb

nodeos --version

cleos version client

keosd -v

nodeos -e -p eosio --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin --contracts-console >> nodeos.log 2>&1 &

tail -n 15 nodeos.log

cleos wallet create --name my_wallet --file my_wallet_password

cat my_wallet_password

export wallet_password=$(cat my_wallet_password)
echo $wallet_password

cleos wallet open --name my_wallet

cleos wallet unlock --name my_wallet --password $wallet_password

cleos wallet import --name my_wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

curl -LO https://github.com/eosio/eosio.cdt/releases/download/v1.8.1/eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb

sudo apt install -y ./eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb

eosio-cpp --version

cleos wallet open --name my_wallet

export wallet_password=$(cat my_wallet_password)
echo $wallet_password

cleos wallet unlock --name my_wallet --password $wallet_password

cleos create key --file my_keypair1

cat my_keypair1

user_private_key=$(grep "Private key:" my_keypair1 | cut -d ' ' -f 3)

user_public_key=$(grep "Public key:" my_keypair1 | cut -d ' ' -f 3)

cleos wallet import --name my_wallet --private-key $user_private_key

cleos create account eosio bob $user_public_key

EOF_CP


gcloud compute scp techcps.sh my-vm-1:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet

gcloud compute ssh my-vm-1 --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/techcps.sh"


