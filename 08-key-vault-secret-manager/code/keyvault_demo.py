import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

vault_url = os.environ["KEY_VAULT_URL"]
secret_name = os.environ.get("KEY_VAULT_SECRET", "StorageConnectionString")

credential = DefaultAzureCredential()
secret_client = SecretClient(vault_url=vault_url, credential=credential)
secret = secret_client.get_secret(secret_name)
print(f"Loaded secret: {secret.name}")
