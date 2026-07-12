import os
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from azure.cognitiveservices.vision.computervision.models import VisualFeatureTypes
from msrest.authentication import CognitiveServicesCredentials

key = os.environ["VISION_KEY"]
endpoint = os.environ["VISION_ENDPOINT"]
image_url = "https://raw.githubusercontent.com/Azure-Samples/cognitive-services-sample-data-files/master/ComputerVision/Images/landmark.jpg"

client = ComputerVisionClient(endpoint, CognitiveServicesCredentials(key))
analysis = client.analyze_image(
    image_url,
    visual_features=[VisualFeatureTypes.description, VisualFeatureTypes.tags, VisualFeatureTypes.objects],
)

print("Description:", analysis.description.captions[0].text)
print("Tags:", [tag.name for tag in analysis.tags])
