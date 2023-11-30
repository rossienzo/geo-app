from flask import Flask
from flask_mqtt import Mqtt
import json

class MQTTService:
   def __init__(self, app):
       self.app = app
       self.mqtt = Mqtt(app)
       self.location_data = {}

   def on_connect(self, client, userdata, flags, rc):
       self.mqtt.subscribe("topic/location")
       self.mqtt.subscribe("topic/accident")
       print(f"Conectado com sucesso! Código: {rc}")

   def on_message(self, client, userdata, message):
       data = json.loads(message.payload.decode('utf-8'))

       client_id = data['client_id']
       latitude = data['message']['position']['latitude']
       longitude = data['message']['position']['longitude']
       self.location_data[client_id] = {'latitude': latitude, 'longitude': longitude}

   def on_disconnect(self, client, userdata, rc):
       global location_data
       client_id = userdata['client_id']
       if client_id in self.location_data:
           del self.location_data[client_id]