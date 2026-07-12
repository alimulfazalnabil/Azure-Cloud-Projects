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
