import paho.mqtt.client as mqtt
import json 

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("topic/data_car")

def on_message(client, userdata, msg):
    data = json.loads(msg.payload.decode('utf-8'))
    print(f"Tópico: {msg.topic} | Mensagem: {data}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

# public broker: mqtt.eclipseprojects.io
client.connect("localhost", 1883, 60)
client.loop_forever()

