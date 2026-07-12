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
