import azure.functions as func
import json


def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps({"message": "Hello from Azure Static Web Apps"}),
        mimetype="application/json",
        status_code=200,
    )
