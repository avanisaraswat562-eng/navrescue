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

  double get accelerationX => accelerometer?.x ?? 0.0;
  double get accelerationY => accelerometer?.y ?? 0.0;
  double get accelerationZ => accelerometer?.z ?? 0.0;

  double get gyroX => gyroscope?.x ?? 0.0;
  double get gyroY => gyroscope?.y ?? 0.0;
  double get gyroZ => gyroscope?.z ?? 0.0;

  double get magnetometerX => magnetometer?.x ?? 0.0;
  double get magnetometerY => magnetometer?.y ?? 0.0;
  double get magnetometerZ => magnetometer?.z ?? 0.0;

  void dispose() {
    accelerometerSubscription?.cancel();
    gyroscopeSubscription?.cancel();
    magnetometerSubscription?.cancel();
  }
}