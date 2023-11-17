import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  late StreamSubscription<UserAccelerometerEvent> accelerometerSubscription;
  double x = 0;
  double y = 0;
  double z = 0;

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
      },
      onError: (error) {},
      cancelOnError: true,
    );
  }

  void stop() {
    accelerometerSubscription.cancel();
  }
}
