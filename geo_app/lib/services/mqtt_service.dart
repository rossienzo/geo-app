import 'dart:convert';

import 'package:geo_app/helpers/toaster.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// public broker: mqtt.eclipseprojects.io
// localhost: 10.0.2.2

class MqttService {
  String serverURI = 'mqtt.eclipseprojects.io';

  late String clientId;
  late MqttServerClient client;

  MqttService();

  Future<MqttConnectionState> connect(String clientId) async {
    try {
      this.clientId = clientId;
      client = MqttServerClient(serverURI, clientId);
      client.port = 1883;
      client.keepAlivePeriod = 20;
      client.onConnected = onConnected;
      client.onDisconnected = onDisconnected;

      // Set Last Will and Testament
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillTopic('topic/disconnection')
          .withWillMessage(jsonEncode(
              {'client_id': clientId, 'message': 'client disconnected'}))
          .withWillQos(MqttQos.atLeastOnce);

      client.connectionMessage = connMessage;

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

  Future<void> subscribeToTopic(String topic) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atMostOnce);
      print('Subscribed to topic: $topic');
    }
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
