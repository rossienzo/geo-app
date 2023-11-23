import 'package:flutter/material.dart';
import 'package:geo_app/services/geolocation_service.dart';
import 'package:geo_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class Configuration extends StatefulWidget {
  final MqttService mqttService;
  final GeolocationService geoService;

  const Configuration(this.mqttService, {Key? key, required this.geoService})
      : super(key: key);

  @override
  State<Configuration> createState() => ConfigurationState();
}

class ConfigurationState extends State<Configuration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () => dialogBuilderConnection(
                      context,
                    ),
                child: createIconText(Icons.topic, 'Conexão do MQTT')),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ],
        ));
  }

  Future<void> dialogBuilder(BuildContext context, String title, String label,
      {bool isInput = true, String bodyText = '', Function? onPressed}) {
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
                  onPressed!();
                }),
          ],
        );
      },
    );
  }

  Future<void> dialogBuilderConnection(BuildContext context) {
    final TextEditingController inputHost =
        TextEditingController(text: widget.mqttService.serverURI);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool connectionStatus =
                widget.mqttService.client.connectionStatus?.state ==
                    MqttConnectionState.connected;

            return AlertDialog(
              title: const Text('Conexão do MQTT'),
              content: !connectionStatus
                  ? TextField(
                      controller: inputHost,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Hostname'),
                    )
                  : Text('Hostname: ${widget.mqttService.serverURI}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child: Text(connectionStatus ? 'Desconectar' : 'Conectar'),
                    onPressed: () async {
                      if (connectionStatus) {
                        widget.mqttService.disconnect();
                        widget.geoService.getPositionPeriodic(stop: true);
                      } else {
                        if (widget.mqttService.serverURI != inputHost.text) {
                          widget.mqttService.serverURI = inputHost.text;
                        }
                        await widget.mqttService.connect();
                        widget.geoService.getPositionPeriodic(seconds: 2);
                      }
                      // Atualiza o dialog
                      setState(() {});
                    }),
              ],
            );
          },
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
