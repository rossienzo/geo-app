import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final TextEditingController inputNumberLocation =
        TextEditingController(text: '2000');

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
                child: createIconText(Icons.topic, 'Alterar conexão do MQTT')),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            GestureDetector(
                onTap: () => dialogBuilder(
                      context,
                      'Alterar tempo de envio de localização',
                      'Tempo (milisegundos)',
                      inputText: inputNumberLocation,
                      onPressed: () {
                        // Para o timer
                        widget.geoService.getPositionPeriodic(stop: true);

                        // Inicia com o novo tempo
                        widget.geoService.getPositionPeriodic(
                            milliseconds: int.parse(inputNumberLocation.text));
                        Navigator.of(context).pop();
                      },
                    ),
                child: createIconText(
                    Icons.alarm, 'Alterar tempo de envio de localização')),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
          ],
        ));
  }

  Future<void> dialogBuilder(BuildContext context, String title, String label,
      {bool isInput = true,
      TextEditingController? inputText,
      String bodyText = '',
      Function? onPressed}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: isInput
              ? TextField(
                  controller: inputText,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Somente números
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

  // Dialog para configurar a conexão do MQTT
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
              title: const Text('Alterar conexão do MQTT'),
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
                        widget.geoService.getPositionPeriodic();
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
