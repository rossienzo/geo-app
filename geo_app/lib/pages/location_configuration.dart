import 'package:flutter/material.dart';
import 'package:geo_app/services/mqtt_service.dart';

class LocationConfiguration extends StatefulWidget {
  const LocationConfiguration({super.key});

  @override
  State<LocationConfiguration> createState() => _LocationConfigurationState();
}

class _LocationConfigurationState extends State<LocationConfiguration> {
  late MqttService mqttService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () =>
                    dialogBuilder(context, 'Alterar tópico MQTT', 'Tópico'),
                child: createIconText(Icons.topic, 'Alterar tópico MQTT')),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ],
        ));
  }

  Future<void> dialogBuilder(BuildContext context, String title, String label,
      {bool isInput = true, String bodyText = ''}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: isInput
              ? TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: label,
                  ),
                )
              : Text(bodyText),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text('Confirmar'),
                onPressed: () {
                  mqttService = MqttService();
                }),
          ],
        );
      },
    );
  }

  // Cria um widget com um ícone e um texto na lista de configurações
  Widget createIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(icon),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
