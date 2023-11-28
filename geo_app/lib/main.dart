import 'package:flutter/material.dart';
import 'package:geo_app/pages/home.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final MqttService mqttService;

  await Geolocator.requestPermission();

  mqttService = MqttService();
  await mqttService.connect();

  runApp(const GeoApp());
}

class GeoApp extends StatelessWidget {
  const GeoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const Home(),
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ));
  }
}
