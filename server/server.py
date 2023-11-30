from flask import Flask, jsonify, render_template
from src.services.mqttService import MQTTService
from flask_socketio import SocketIO

app = Flask(__name__)
app.template_folder = './src/templates'
app.config['MQTT_BROKER_URL'] = 'mqtt.eclipseprojects.io' # public broker: mqtt.eclipseprojects.io
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_KEEPALIVE'] = 60
app.config['MQTT_TLS_ENABLED'] = False
app.config["SECRET_KEY"] = "!@#$%^&*()_+"

mqtt = MQTTService(app)
io = SocketIO(app)

# MQTT
@mqtt.mqtt.on_connect()
def handle_connect(client, userdata, flags, rc):
   mqtt.on_connect(client, userdata, flags, rc)

@mqtt.mqtt.on_message()
def handle_mqtt_message(client, userdata, message):
   mqtt.on_message(client, userdata, message)

@mqtt.mqtt.on_disconnect()
def handle_disconnect(client, userdata, rc):
   mqtt.on_disconnect(client, userdata, rc)


# HTTP
@app.route('/location/<client_id>')
def location(client_id):
   print('client_id', client_id)
   if client_id in mqtt.location_data:
      return jsonify(mqtt.location_data[client_id])
   else:
      return jsonify({'error': 'client_id not found'}), 404
  
@app.route('/')
def home():
   client_ids = list(mqtt.location_data.keys())
   return render_template('index.html', client_ids=client_ids)

@app.route('/client/<client_id>')
def client_page(client_id):
   return render_template('client.html', client_id=client_id)

if __name__ == '__main__':
   io.run(app, port=5000)