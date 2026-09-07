import '../models/navigation_data.dart';
import '../navigation/dead_reckoning.dart';
import '../sensors/sensor_service.dart';

class NavigationController {
  DeadReckoning? deadReckoning;

  NavigationData? currentData;

  final SensorService sensorService;

  NavigationController(this.sensorService);

  void updatePosition({
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required bool gnssAvailable,
    required bool deadReckoningMode,
  }) {
    currentData = NavigationData(
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      heading: heading,
      gnssAvailable: gnssAvailable,
      deadReckoning: deadReckoningMode,

      accelerationX: sensorService.accelerationX,
      accelerationY: sensorService.accelerationY,
      accelerationZ: sensorService.accelerationZ,

      gyroX: sensorService.gyroX,
      gyroY: sensorService.gyroY,
      gyroZ: sensorService.gyroZ,

      magnetometerX: sensorService.magnetometerX,
      magnetometerY: sensorService.magnetometerY,
      magnetometerZ: sensorService.magnetometerZ,
    );
  }

  void startDeadReckoning({
    required double latitude,
    required double longitude,
  }) {
    deadReckoning = DeadReckoning(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void updateDeadReckoning({
    required double speed,
    required double heading,
    required double deltaTime,
  }) {
    if (deadReckoning == null) return;

    deadReckoning!.update(
      speed: speed,
      heading: heading,
      deltaTime: deltaTime,
    );
  }
}