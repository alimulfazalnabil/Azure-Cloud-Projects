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
