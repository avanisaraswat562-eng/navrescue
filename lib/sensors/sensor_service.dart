import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? magnetometerSubscription;

  AccelerometerEvent? accelerometer;
  GyroscopeEvent? gyroscope;
  MagnetometerEvent? magnetometer;

  void start() {
    accelerometerSubscription =
        accelerometerEventStream().listen((event) {
          accelerometer = event;
        });

    gyroscopeSubscription =
        gyroscopeEventStream().listen((event) {
          gyroscope = event;
        });

    magnetometerSubscription =
        magnetometerEventStream().listen((event) {
          magnetometer = event;
        });
  }

  void dispose() {
    accelerometerSubscription?.cancel();
    gyroscopeSubscription?.cancel();
    magnetometerSubscription?.cancel();
  }
}