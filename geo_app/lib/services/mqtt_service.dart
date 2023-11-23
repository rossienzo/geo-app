import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

// public broker: mqtt.eclipseprojects.io

class MqttService {
  String serverURI = '10.0.2.2'; // localhost

  late String clientId;
  late MqttServerClient client;

  MqttService();

  Future<MqttConnectionState> connect() async {
    try {
      clientId = const Uuid().v1();
      client = MqttServerClient(serverURI, clientId);
      client.port = 1883;
      client.keepAlivePeriod = 60;
      client.onConnected = onConnected;
      client.onDisconnected = onDisconnected;

      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Client connected successfully');
    } else {
      print('Connection failed - disconnecting');
      client.disconnect();
    }
    return client.connectionStatus!.state;
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
    print('Disconnected from MQTT broker.');
  }
}
