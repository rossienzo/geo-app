from flask import Flask, jsonify, render_template
from flask_mqtt import Mqtt
import json

app = Flask(__name__)
app.config['MQTT_BROKER_URL'] = 'mqtt.eclipseprojects.io' # public broker: mqtt.eclipseprojects.io
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_KEEPALIVE'] = 60
app.config['MQTT_TLS_ENABLED'] = False

mqtt = Mqtt(app)
location_data = {}

# MQTT
@mqtt.on_connect()
def handle_connect(client, userdata, flags, rc):
   print("Connected with result code "+str(rc))
   mqtt.subscribe("topic/location")
   mqtt.subscribe("topic/accident")

@mqtt.on_message()
def handle_mqtt_message(client, userdata, message):
   global location_data
   data = json.loads(message.payload.decode('utf-8'))

   client_id = data['client_id']
   latitude = data['message']['position']['latitude']
   longitude = data['message']['position']['longitude']
   location_data[client_id] = {'latitude': latitude, 'longitude': longitude}
   #print(f"Tópico: {message.topic} | Mensagem: {data}")

@mqtt.on_disconnect()
def handle_disconnect(client, userdata, rc):
   global location_data
   client_id = userdata['client_id']
   if client_id in location_data:
      del location_data[client_id]


# HTTP
@app.route('/location/<client_id>')
def location(client_id):
  if client_id in location_data:
      return jsonify(location_data[client_id])
  else:
      return jsonify({'error': 'client_id not found'}), 404
  
@app.route('/')
def home():
   client_ids = list(location_data.keys())
   return render_template('index.html', client_ids=client_ids)


@app.route('/client/<client_id>')
def client_page(client_id):
   return render_template('client.html', client_id=client_id)

if __name__ == '__main__':
   app.run(host='127.0.0.1', port=5000)