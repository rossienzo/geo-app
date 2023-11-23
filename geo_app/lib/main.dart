import 'package:flutter/material.dart';
import 'package:geo_app/pages/home.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  final MqttService mqttService;

  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  mqttService = MqttService();
  await mqttService.connect();

  runApp(GeoApp());
}

class GeoApp extends StatelessWidget {
  const GeoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Home(),
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ));
  }
}
