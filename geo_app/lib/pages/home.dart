import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geo_app/services/geolocation_service.dart';
import 'package:geo_app/services/accelerometer_service.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  late MqttService mqttService;
  late GeolocationService geoService;
  late AccelerometerService accService;
  late bool collision = false;

  HomeState() {
    mqttService = MqttService();
    mqttService.connect();

    geoService = GeolocationService();
    accService = AccelerometerService();

    /*
    // Inicia a simulação de batida a cada 5 segundos (por exemplo)
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (accService.simulateCollision()) {
        collision = true;
        sendData('topic/accident', qos: 2);
      }
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.location_on_outlined),
        title: const Text('GeoApp'),
      ),
      body: ChangeNotifierProvider<GeolocationService>(create: (context) {
        final geoService = GeolocationService();

        geoService.startTimer();
        return geoService;
      }, child: Builder(builder: (context) {
        final local = context.watch<GeolocationService>();
        String message = 'Carregando...';

        if (local.lat != 0 && local.long != 0) {
          // Escreve a mensagem no app
          message = local.error == ''
              ? 'Latitude: ${local.lat}\nLongitude: ${local.long} \nBatida: ${collision}'
              : local.error;

          // Envia informações para o broker
          if (mqttService.client.connectionStatus?.state ==
              MqttConnectionState.connected) {
            sendData('topic/location');
          } else {
            message = 'Sem conexão com o broker';
          }
        }

        return Center(child: Text(message));
      })),
    );
  }

  sendData(topic, {qos = 1}) {
    var data = {
      'topic': topic,
      'client_id': mqttService.clientId,
      'message': {
        'position': {
          'latitude': geoService.lat,
          'longitude': geoService.long,
        }
      }
    };

    mqttService.publishMessage(topic, jsonEncode(data), qos: qos);
  }
}
