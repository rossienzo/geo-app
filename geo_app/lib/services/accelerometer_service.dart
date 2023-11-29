import 'dart:async';
import 'dart:math';

import 'package:geo_app/helpers/toaster.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
  double x = 0;
  double y = 0;
  double z = 0;
  double previousTotalAcceleration = 0.0;

  // Configuração da sensibilidade da detecção de acidente
  double threshold = 14.0;

  AccelerometerService() {
    start();
  }

  void start() {
    accelerometerSubscription = userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        x = event.x;
        y = event.y;
        z = event.z;
        //print('x: $x, y: $y, z: $z');
        detectCollision(event.x, event.y, event.z);
      },
      onError: (error) {},
      cancelOnError: true,
    );
  }

  void stop() {
    accelerometerSubscription.cancel();
  }

  bool detectCollision(double x, double y, double z) {
    double totalAcceleration = sqrt(x * x + y * y + z * z);

    // Verifica se houve uma mudança brusca na aceleração total
    if ((totalAcceleration - previousTotalAcceleration).abs() > threshold) {
      Toaster.showToast('Batida detectada!');
      print("Batida detectada!");
      return true;
    }

    previousTotalAcceleration = totalAcceleration;
    return false;
  }

  // Simula a batida
  bool simulateCollision() {
    // Valores entre -10 e 10
    double simulatedX = Random().nextDouble() * 20 - 10;
    double simulatedY = Random().nextDouble() * 20 - 10;
    double simulatedZ = Random().nextDouble() * 20 - 10;

    return detectCollision(simulatedX, simulatedY, simulatedZ);
  }

  bool collision() {
    return detectCollision(30, 30, 30);
  }
}
