import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationController extends ChangeNotifier {
  MqttService mqttService;
  double lat = 0.0;
  double long = 0.0;
  String error = '';

  GeolocationController(this.mqttService) {
    Timer.periodic(const Duration(seconds: 5), (Timer t) => getPosition());
  }

  // Envia a localização para o broker
  void publishLocation() {
    final message = '{"latitude": $lat, "longitude": $long}';
    mqttService.publishMessage('location_topic', message);
  }

  // Recebe atualizações de localização do broker
  void subscribeToLocationUpdates() {
    mqttService.subscribe('location_topic');
    mqttService.setOnMessageReceived((message) {
      print('Recebendo atualizações: ${message.payload}');
    });
  }

  // Pega a posição atual
  getPosition() async {
    try {
      Position position = await currentPosition();
      lat = position.latitude;
      long = position.longitude;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  // Autorização de localização
  Future<Position> currentPosition() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }
}
