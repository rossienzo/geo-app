import 'dart:convert';

import 'package:geo_app/helpers/toaster.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

// public broker: mqtt.eclipseprojects.io
// localhost: 10.0.2.2

class MqttService {
  String serverURI = '10.0.2.2';

  late String clientId;
  late MqttServerClient client;

  MqttService();

  Future<MqttConnectionState> connect(String clientId) async {
    try {
      this.clientId = clientId;
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

  void disconnect() async {
    await disconnectionMessage();
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
    Toaster.showToast('Cliente conectado com sucesso.');
    print('Connected to MQTT broker.');
  }

  void onDisconnected() {
    Toaster.showToast('Cliente desconectado.');
    print('Disconnected from MQTT broker.');
  }

  Future<void> disconnectionMessage() async {
    publishMessage("topic/disconnection", jsonEncode(clientId), qos: 2);
  }
}
