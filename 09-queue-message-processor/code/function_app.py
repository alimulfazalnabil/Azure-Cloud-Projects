import azure.functions as func
import logging

app = func.FunctionApp()

@app.queue_trigger(arg_name="msg", queue_name="orders", connection="AzureWebJobsStorage")
def process_order(msg: func.QueueMessage) -> None:
    logging.info("Processing message: %s", msg.get_body().decode())
