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
  late GeolocationService glcs;
  late AccelerometerService accs;

  HomeState() {
    mqttService = MqttService();
    mqttService.connect();

    glcs = GeolocationService();
    accs = AccelerometerService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.location_on_outlined),
        title: const Text('GeoApp'),
      ),
      body: ChangeNotifierProvider<GeolocationService>(
          create: (context) => GeolocationService(),
          child: Builder(builder: (context) {
            final local = context.watch<GeolocationService>();
            String message = 'Carregando...';

            if (local.lat != 0 && local.long != 0) {
              message = local.error == ''
                  ? 'Latitude: ${local.lat}\nLongitude: ${local.long}'
                  : local.error;

              // Envia informações para o broker
              if (mqttService.client.connectionStatus?.state ==
                  MqttConnectionState.connected) {
                //mqttService.publishMessage('location_topic','{"latitude": ${local.lat}, "longitude": ${local.long}}');
                String topic = 'data_car_topic';
                String jsonData =
                    '{"topic": "$topic", "message": {"position": {"latitude": "${local.lat}", "longitude": "${local.long}"}, "accelerometer": {"x": "${accs.x}", "y": "${accs.y}", "z": "${accs.z}"}}}';

                mqttService.publishMessage(topic, jsonData);
              } else {
                message = 'Sem conexão com o broker';
              }
            }

            return Center(child: Text(message));
          })),
    );
  }
}
