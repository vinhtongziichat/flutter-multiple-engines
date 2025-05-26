import asyncio
import websockets
import random
import json
from datetime import datetime

# Set to store all connected clients
CLIENTS = set()
count = 0
jsonData = {}

with open('256KB.json', 'r') as file:
    jsonData = json.load(file)

async def broadcast_random_message():
    """Send a random message to all connected clients every 0.5 seconds."""
    global count
    while True:
        if CLIENTS:
            count = count + 1
            if count > 1000000:
                count = 0
            current_time = datetime.now().strftime("%H:%M:%S")
            message_json = json.dumps({"data": jsonData, "content": f"{current_time} => {count}"})
            tasks = [client.send(message_json) for client in CLIENTS]
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)
        await asyncio.sleep(0.1)

async def handle_client(websocket):
    """Handle individual client connections."""
    # Register client and print connection message
    CLIENTS.add(websocket)
    print(f"Client connected: {websocket.remote_address}")
    try:
        async for message in websocket:
            # Parse incoming message
            try:
                data = json.loads(message)
                client_message = data.get("content", "No content")
                # Echo back the received message
                response = json.dumps({"type": "echo", "content": f"Received: {client_message}"})
                await websocket.send(response)
            except json.JSONDecodeError:
                await websocket.send(json.dumps({"type": "error", "content": "Invalid JSON format"}))
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        # Unregister client
        CLIENTS.remove(websocket)
        print(f"Client disconnected: {websocket.remote_address}")

async def main():
    """Start the WebSocket server and broadcasting task."""
    # Start the broadcasting task
    broadcast_task = asyncio.create_task(broadcast_random_message())
    
    # Start the WebSocket server
    server = await websockets.serve(handle_client, "localhost", 8765)
    
    # Keep the server running
    await server.wait_closed()
    broadcast_task.cancel()

if __name__ == "__main__":
    asyncio.run(main())