import paho.mqtt.client as mqtt
import json 

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    client.subscribe("location_topic")

def on_message(client, userdata, msg):
    data = json.loads(msg.payload.decode('utf-8'))
    print(f"ID do cliente: {client}, Tópico: {msg.topic} | Mensagem: {data}")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("mqtt.eclipseprojects.io", 1883, 60)
client.loop_forever()

