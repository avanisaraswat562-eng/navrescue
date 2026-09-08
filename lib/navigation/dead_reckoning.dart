import 'dart:math';

class DeadReckoning {
  double latitude;
  double longitude;

  DeadReckoning({
    required this.latitude,
    required this.longitude,
  });

  void update({
    required double speed,
    required double heading,
    required double deltaTime,
  }) {
    final speedMetersPerSecond = speed / 3.6;
    final distance = speedMetersPerSecond * deltaTime;

    final headingRadians = heading * pi / 180;

    final northMovement = distance * cos(headingRadians);
    final eastMovement = distance * sin(headingRadians);

    latitude += northMovement / 111320;

    longitude +=
        eastMovement /
            (111320 * cos(latitude * pi / 180));
  }
}