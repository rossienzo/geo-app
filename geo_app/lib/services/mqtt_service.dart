import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  late MqttServerClient client;

  MqttService() {
    client = MqttServerClient('mqtt.eclipseprojects.io', const Uuid().v1());
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }

  void connect() {
    client.connect();
  }

  void disconnect() {
    client.disconnect();
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
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
