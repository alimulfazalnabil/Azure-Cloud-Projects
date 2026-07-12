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
