
gcloud auth list

gcloud services enable firestore.googleapis.com

gcloud firestore databases create --location=nam5 --type=datastore-mode

cat > insert_task.py << 'EOF_CP'
from google.cloud import datastore
from datetime import datetime

# Initialize client
client = datastore.Client()

# Define the kind and create a task entity
kind = "Task"
task_key = client.key(kind)

task = datastore.Entity(key=task_key)
task.update({
    "description": "Learn Google Cloud Datastore",
    "created": datetime.utcnow(),
    "done": False
})

client.put(task)
print("Task entity added successfully.")
EOF_CP

python3 -m venv env
source env/bin/activate

pip install google-cloud-datastore

python insert_task.py

