from flask import Flask, jsonify, render_template
from flask_mqtt import Mqtt
import json

app = Flask(__name__)
app.config['MQTT_BROKER_URL'] = 'localhost'
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_KEEPALIVE'] = 60
app.config['MQTT_TLS_ENABLED'] = False

mqtt = Mqtt(app)
latitude = None
longitude = None

@mqtt.on_connect()
def handle_connect(client, userdata, flags, rc):
   print("Connected with result code "+str(rc))
   mqtt.subscribe("topic/location")
   mqtt.subscribe("topic/accident")

@mqtt.on_message()
def handle_mqtt_message(client, userdata, message):
   global latitude, longitude
   data = json.loads(message.payload.decode('utf-8'))

   latitude = data['message']['position']['latitude']
   longitude = data['message']['position']['longitude']
   print(f"Tópico: {message.topic} | Mensagem: {data}")


@app.route('/')
def home():
   return render_template('index.html')

@app.route('/location')
def location():
   return jsonify({'latitude': latitude, 'longitude': longitude})


if __name__ == '__main__':
   app.run(host='127.0.0.1', port=5000)