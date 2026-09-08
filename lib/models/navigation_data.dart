class NavigationData {
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;

  final bool gnssAvailable;
  final bool deadReckoning;

  final double accelerationX;
  final double accelerationY;
  final double accelerationZ;

  final double gyroX;
  final double gyroY;
  final double gyroZ;

  final double magnetometerX;
  final double magnetometerY;
  final double magnetometerZ;

  NavigationData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.gnssAvailable,
    required this.deadReckoning,
    required this.accelerationX,
    required this.accelerationY,
    required this.accelerationZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.magnetometerX,
    required this.magnetometerY,
    required this.magnetometerZ,
  });
}