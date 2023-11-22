import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

// public broker: mqtt.eclipseprojects.io
const String serverURI = '10.0.2.2'; // localhost

class MqttService {
  late String clientId;
  late MqttServerClient client;

  MqttService() {
    clientId = const Uuid().v1();
    client = MqttServerClient(serverURI, clientId);
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }

  void connect() {
    client.connect();
  }

  void disconnect() {
    client.disconnect();
  }

  void publishMessage(String topic, String message, {int qos = 1}) {
    MqttQos mqttQos;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    switch (qos) {
      case 0:
        mqttQos = MqttQos.atMostOnce;
        break;
      case 1:
        mqttQos = MqttQos.atLeastOnce;
        break;
      case 2:
        mqttQos = MqttQos.exactlyOnce;
        break;
      default:
        mqttQos = MqttQos.atLeastOnce;
    }
    print(mqttQos);

    client.publishMessage(topic, mqttQos, builder.payload!);
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void setOnMessageReceived(void Function(MqttPublishMessage) callback) {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      callback(recMess);
    });
  }

  void onConnected() {
    print('Connected to MQTT broker.');
  }

  void onDisconnected() {
    print('Connected to MQTT broker.');
  }
}
