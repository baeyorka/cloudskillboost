


export ID="$(gcloud projects list --format='value(PROJECT_ID)')"

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

cat > generate_bouquet.py <<EOF_CP
import vertexai
from vertexai.preview.vision_models import ImageGenerationModel

def generate_bouquet_image(prompt: str):
    vertexai.init(project="$ID", location="$REGION")
    model = ImageGenerationModel.from_pretrained("imagen-3.0-generate-002")
    
    images = model.generate_images(
        prompt=prompt,
        number_of_images=1,
        seed=1,
        add_watermark=False
    )

    images[0].save(location="bouquet.jpeg")
    print("Image saved as bouquet.jpeg")

# Call the function with the challenge prompt
generate_bouquet_image("Create an image containing a bouquet of 2 sunflowers and 3 roses")
EOF_CP

sleep 10

/usr/bin/python3 /home/student/generate_bouquet.py


export ID="$(gcloud projects list --format='value(PROJECT_ID)')"

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")


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

project_id = "$ID"
location = "$REGION"

response = generate_text(project_id, location)
print(response)
EOF_CP

/usr/bin/python3 /home/student/genai.py

sleep 45

/usr/bin/python3 /home/student/genai.py

