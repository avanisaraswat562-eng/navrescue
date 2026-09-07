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
    // Speed: km/h → m/s
    final speedMetersPerSecond = speed / 3.6;

    // Distance travelled during this time interval
    final distance =
        speedMetersPerSecond * deltaTime;

    // Convert heading to radians
    final headingRadians =
        heading * pi / 180;

    // Calculate movement
    final northMovement =
        distance * cos(headingRadians);

    final eastMovement =
        distance * sin(headingRadians);

    // Convert metres to latitude/longitude changes
    latitude += northMovement / 111320;

    longitude +=
        eastMovement /
            (111320 * cos(latitude * pi / 180));
  }
}