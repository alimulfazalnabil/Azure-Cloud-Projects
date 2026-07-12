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
