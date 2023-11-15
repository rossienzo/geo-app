import 'package:flutter/material.dart';
import 'package:geo_app/controllers/geolocation_controller.dart';
import 'package:geo_app/services/mqtt_service.dart';
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
        title: const Text('GeoApp'),
      ),
      body: ChangeNotifierProvider<GeolocationController>(
          create: (context) => GeolocationController(mqttService),
          child: Builder(builder: (context) {
            final local = context.watch<GeolocationController>();

            // Envia informações para o broker
            glc.publishLocation();

            String mensagem = local.error == ''
                ? 'Latitude: ${local.lat} | Longitude: ${local.long}'
                : local.error;

            return Center(child: Text(mensagem));
          })),
    );
  }
}
