import 'package:flutter/material.dart';
import 'package:geo_app/controllers/geolocation_controller.dart';
import 'package:geo_app/pages/location_configuration.dart';
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
  late GeolocationController glc;

  HomeState() {
    mqttService = MqttService();
    mqttService.connect();

    glc = GeolocationController(mqttService);
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
                      builder: (context) => LocationConfiguration()),
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
      body: ChangeNotifierProvider<GeolocationController>(
          create: (context) => GeolocationController(mqttService),
          child: Builder(builder: (context) {
            final local = context.watch<GeolocationController>();
            String mensagem = 'Carregando...';

            if (local.lat != 0 && local.long != 0) {
              mensagem = local.error == ''
                  ? 'Latitude: ${local.lat}\nLongitude: ${local.long}'
                  : local.error;

              // Envia informações para o broker
              if (glc.mqttService.client.connectionStatus?.state ==
                  MqttConnectionState.connected) {
                glc.publishLocation();
              } else {
                mensagem = 'Sem conexão com o broker';
              }
            }

            return Center(child: Text(mensagem));
          })),
    );
  }
}
