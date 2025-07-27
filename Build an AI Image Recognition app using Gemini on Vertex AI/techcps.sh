
read -e -p $'\033[1;33mEnter the REGION: \033[0m' REGION

CP="$(gcloud projects list --format='value(PROJECT_ID)')"

cat > genai.py <<EOF_CP
import vertexai
from vertexai.generative_models import GenerativeModel, Part


def generate_text(project_id: str, location: str) -> str:
    # Initialize Vertex AI
    vertexai.init(project=project_id, location=location)
    # Load the model
    multimodal_model = GenerativeModel("gemini-2.0-flash-001")
    # Query the model
    response = multimodal_model.generate_content(
        [
            # Add an example image
            Part.from_uri(
                "gs://generativeai-downloads/images/scones.jpg", mime_type="image/jpeg"
            ),
            # Add an example query
            "what is shown in this image?",
        ]
    )

    return response.text

# --------  Important: Variable declaration  --------

project_id = "$CP"
location = "$REGION"

#  --------   Call the Function  --------

response = generate_text(project_id, location)
print(response)
EOF_CP


sleep 5

/usr/bin/python3 /home/student/genai.py


sleep 30

/usr/bin/python3 /home/student/genai.py


