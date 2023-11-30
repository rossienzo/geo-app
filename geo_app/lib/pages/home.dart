import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geo_app/helpers/user_preferences.dart';
import 'package:geo_app/pages/configuration.dart';
import 'package:geo_app/services/geolocation_service.dart';
import 'package:geo_app/services/accelerometer_service.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  late MqttService mqttService = MqttService();
  late GeolocationService geoService;
  late AccelerometerService accService;
  late bool collision = false;

  @override
  void initState() {
    super.initState();
    mqttService.connect(UserPreferences.userId);
    geoService = GeolocationService();
    accService = AccelerometerService();
  }

  HomeState() {
    // Inicia a simulação de batida a cada 5 segundos
    /* 
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
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Geolocation') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Configuration(
                            mqttService,
                            geoService: geoService,
                          )),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Geolocation',
                child: Text('Configurações'),
              ),
            ],
          ),
        ],
      ),
      body: ChangeNotifierProvider<GeolocationService>(create: (context) {
        geoService.getPositionPeriodic();
        return geoService;
      }, child: Builder(builder: (context) {
        final local = context.watch<GeolocationService>();
        String message = 'Carregando...';

        if (local.lat != 0 && local.long != 0) {
          // Escreve a mensagem no app
          message = local.error == ''
              ? 'Latitude: ${local.lat}\nLongitude: ${local.long} \nBatida: $collision'
              : local.error;

          // Envia informações para o broker
          if (mqttService.client.connectionStatus?.state ==
              MqttConnectionState.connected) {
            sendData('topic/location');
          } else {
            message = 'Sem conexão com o broker';
          }
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.yellowAccent),
                ),
                onPressed: () {
                  if (accService.collision()) {
                    collision = true;
                    sendData('topic/accident', qos: 2);
                  }
                },
                child: const Text('Simular batida'),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(mqttService.clientId,
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.blueGrey,
                    ))),
            Align(
                alignment: Alignment.center,
                child: Text(message,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.indigo,
                    ))),
          ],
        );
      })),
    );
  }

  sendData(topic, {qos = 1}) {
    var data = {
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
