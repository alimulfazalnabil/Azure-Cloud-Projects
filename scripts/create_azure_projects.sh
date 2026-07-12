#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-azure-projects}"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

cat > README.md <<'EOF'
# Azure Cloud Projects

This repository contains 10 Azure-focused projects that are suitable for a cloud engineering portfolio. Each project includes a README, working Python code, and a requirements file.

## Project list

1. Serverless HTTP API
2. To-Do API with Cosmos DB
3. Blob Storage File Uploader
4. AI Image Analyzer
5. Static Web App with API
6. IoT Hub Data Simulator
7. Azure DevOps CI/CD Pipeline
8. Key Vault Secret Manager
9. Queue Storage Message Processor
10. Azure ML AutoML Sample

## Getting started

Run the generator from the repository root:

```bash
bash scripts/create_azure_projects.sh
```

Then open any project folder and follow the instructions in its README.
EOF

create_project_folder() {
  local folder="$1"
  local title="$2"
  local description="$3"

  mkdir -p "$folder/code"
  cat > "$folder/README.md" <<EOF
# $title

## Overview
$description

## Prerequisites
- Azure subscription
- Python 3.10+
- Azure CLI or VS Code Azure extensions

## Getting started
1. Navigate to the code directory.
2. Install requirements with pip install -r requirements.txt.
3. Replace placeholder values such as connection strings and resource names.
4. Deploy the sample to Azure.
EOF
}

create_project_folder "01-serverless-http-api" "Serverless HTTP API" "A simple Azure Function that returns a JSON greeting from an HTTP trigger."
cat > "01-serverless-http-api/code/function_app.py" <<'EOF'
import azure.functions as func
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="hello")
def hello(req: func.HttpRequest) -> func.HttpResponse:
    name = req.params.get("name", "World")
    payload = {"message": f"Hello, {name}!"}
    return func.HttpResponse(
        json.dumps(payload),
        mimetype="application/json",
        status_code=200,
    )
EOF
cat > "01-serverless-http-api/code/requirements.txt" <<'EOF'
azure-functions
EOF

create_project_folder "02-cosmosdb-todo-api" "To-Do API with Cosmos DB" "A Python sample that stores items in Azure Cosmos DB using the Azure Cosmos SDK."
cat > "02-cosmosdb-todo-api/code/cosmos_todo.py" <<'EOF'
import os
import uuid
from azure.cosmos import CosmosClient

endpoint = os.environ["COSMOS_ENDPOINT"]
key = os.environ["COSMOS_KEY"]
db_name = os.environ.get("COSMOS_DB", "todo-db")
container_name = os.environ.get("COSMOS_CONTAINER", "items")

client = CosmosClient(endpoint, key)
database = client.get_database_client(db_name)
container = database.get_container_client(container_name)


def create_item(title: str):
    item = {"id": str(uuid.uuid4()), "title": title, "completed": False}
    container.upsert_item(item)
    return item


def list_items():
    query = "SELECT * FROM c"
    return list(container.query_items(query=query, enable_cross_partition=True))


if __name__ == "__main__":
    print(create_item("Deploy to Azure"))
    print(list_items())
EOF
cat > "02-cosmosdb-todo-api/code/requirements.txt" <<'EOF'
azure-cosmos
EOF

create_project_folder "03-blob-storage-uploader" "Blob Storage File Uploader" "A Flask app that uploads content to Azure Blob Storage and lists uploaded blobs."
mkdir -p "03-blob-storage-uploader/code/templates"
cat > "03-blob-storage-uploader/code/app.py" <<'EOF'
import os
from flask import Flask, request, render_template
from azure.storage.blob import BlobServiceClient

app = Flask(__name__)
connection_string = os.environ["AZURE_STORAGE_CONNECTION_STRING"]
container_name = os.environ.get("AZURE_STORAGE_CONTAINER", "uploads")
blob_service = BlobServiceClient.from_connection_string(connection_string)


@app.route("/")
def index():
    container_client = blob_service.get_container_client(container_name)
    blobs = [blob.name for blob in container_client.list_blobs()]
    return render_template("index.html", blobs=blobs)


@app.route("/upload", methods=["POST"])
def upload():
    file = request.files["file"]
    blob_client = blob_service.get_blob_client(container=container_name, blob=file.filename)
    blob_client.upload_blob(file.read(), overwrite=True)
    return f"Uploaded {file.filename}"


if __name__ == "__main__":
    app.run(debug=True)
EOF
cat > "03-blob-storage-uploader/code/templates/index.html" <<'EOF'
<!doctype html>
<html>
  <body>
    <h1>Azure Blob Uploader</h1>
    <form method="post" action="/upload" enctype="multipart/form-data">
      <input type="file" name="file" />
      <button type="submit">Upload</button>
    </form>
    <h2>Existing files</h2>
    <ul>
      {% for blob in blobs %}
      <li>{{ blob }}</li>
      {% endfor %}
    </ul>
  </body>
</html>
EOF
cat > "03-blob-storage-uploader/code/requirements.txt" <<'EOF'
flask
azure-storage-blob
EOF

create_project_folder "04-ai-image-analyzer" "AI Image Analyzer" "A Python sample that uses Azure Cognitive Services Computer Vision to describe an image."
cat > "04-ai-image-analyzer/code/analyze.py" <<'EOF'
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
EOF
cat > "04-ai-image-analyzer/code/requirements.txt" <<'EOF'
azure-cognitiveservices-vision-computervision
msrest
requests
EOF

create_project_folder "05-static-webapp-with-api" "Static Web App with API" "A simple static website plus an Azure Function API back end."
mkdir -p "05-static-webapp-with-api/code/api"
cat > "05-static-webapp-with-api/code/api/hello.py" <<'EOF'
import azure.functions as func
import json


def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps({"message": "Hello from Azure Static Web Apps"}),
        mimetype="application/json",
        status_code=200,
    )
EOF
cat > "05-static-webapp-with-api/code/index.html" <<'EOF'
<!doctype html>
<html>
  <body>
    <h1>Azure Static Web App</h1>
    <button onclick="fetch('/api/hello').then(r => r.json()).then(d => alert(d.message))">
      Call API
    </button>
  </body>
</html>
EOF
cat > "05-static-webapp-with-api/code/requirements.txt" <<'EOF'
azure-functions
EOF

create_project_folder "06-iot-hub-simulator" "IoT Hub Data Simulator" "A Python client that sends telemetry to Azure IoT Hub."
cat > "06-iot-hub-simulator/code/simulate_device.py" <<'EOF'
import asyncio
import json
import os
import random
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import Message

connection_string = os.environ["IOTHUB_DEVICE_CONNECTION_STRING"]


async def main():
    device_client = IoTHubDeviceClient.create_from_connection_string(connection_string)
    await device_client.connect()
    for _ in range(5):
        payload = {
            "temperature": round(random.uniform(20.0, 30.0), 2),
            "humidity": round(random.uniform(40.0, 80.0), 2),
        }
        message = Message(json.dumps(payload))
        await device_client.send_message(message)
        print(f"Sent: {payload}")
        await asyncio.sleep(2)
    await device_client.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
EOF
cat > "06-iot-hub-simulator/code/requirements.txt" <<'EOF'
azure-iot-device
EOF

create_project_folder "07-azure-devops-cicd" "Azure DevOps CI/CD Pipeline" "A YAML pipeline that builds a Python app and deploys it to Azure App Service."
cat > "07-azure-devops-cicd/code/app.py" <<'EOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Azure DevOps deployment demo"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
EOF
cat > "07-azure-devops-cicd/code/azure-pipelines.yml" <<'EOF'
trigger:
  - main

pool:
  vmImage: ubuntu-latest

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.10'
  - script: |
      python -m pip install --upgrade pip
      pip install -r requirements.txt
    displayName: 'Install dependencies'
  - task: AzureWebApp@1
    inputs:
      azureSubscription: 'YourServiceConnection'
      appName: 'my-python-app'
      package: '$(System.DefaultWorkingDirectory)'
EOF
cat > "07-azure-devops-cicd/code/requirements.txt" <<'EOF'
flask
EOF

create_project_folder "08-key-vault-secret-manager" "Key Vault Secret Manager" "A Python sample that retrieves secrets from Azure Key Vault using managed identity or service principal credentials."
cat > "08-key-vault-secret-manager/code/keyvault_demo.py" <<'EOF'
import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

vault_url = os.environ["KEY_VAULT_URL"]
secret_name = os.environ.get("KEY_VAULT_SECRET", "StorageConnectionString")

credential = DefaultAzureCredential()
secret_client = SecretClient(vault_url=vault_url, credential=credential)
secret = secret_client.get_secret(secret_name)
print(f"Loaded secret: {secret.name}")
EOF
cat > "08-key-vault-secret-manager/code/requirements.txt" <<'EOF'
azure-identity
azure-keyvault-secrets
EOF

create_project_folder "09-queue-message-processor" "Queue Storage Message Processor" "A simple Azure Function that processes queue messages from Azure Storage Queue."
cat > "09-queue-message-processor/code/function_app.py" <<'EOF'
import azure.functions as func
import logging

app = func.FunctionApp()

@app.queue_trigger(arg_name="msg", queue_name="orders", connection="AzureWebJobsStorage")
def process_order(msg: func.QueueMessage) -> None:
    logging.info("Processing message: %s", msg.get_body().decode())
EOF
cat > "09-queue-message-processor/code/requirements.txt" <<'EOF'
azure-functions
EOF

create_project_folder "10-azure-ml-automl" "Azure ML AutoML Sample" "A starter script that shows how to submit an AutoML job against Azure Machine Learning."
cat > "10-azure-ml-automl/code/automl.py" <<'EOF'
import os
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

subscription_id = os.environ["AZURE_SUBSCRIPTION_ID"]
resource_group = os.environ["AZURE_RESOURCE_GROUP"]
workspace_name = os.environ["AZURE_ML_WORKSPACE"]

ml_client = MLClient(
    DefaultAzureCredential(),
    subscription_id,
    resource_group,
    workspace_name,
)

print("Connected to Azure ML workspace:", workspace_name)
print("Use this file to submit AutoML jobs from your Azure ML workspace.")
EOF
cat > "10-azure-ml-automl/code/requirements.txt" <<'EOF'
azure-ai-ml
azure-identity
EOF

printf 'Repository scaffold created at %s\n' "$ROOT_DIR"
