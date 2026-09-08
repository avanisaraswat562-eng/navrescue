import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const NavRescueApp());
}

class NavRescueApp extends StatelessWidget {
  const NavRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NavRescue',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const NavRescueDashboard(),
    );
  }
}

class NavRescueDashboard extends StatefulWidget {
  const NavRescueDashboard({super.key});

  @override
  State<NavRescueDashboard> createState() => _NavRescueDashboardState();
}

class _NavRescueDashboardState extends State<NavRescueDashboard> {
  Timer? sensorUiTimer;

  
  AccelerometerEvent? accelerometer;
  GyroscopeEvent? gyroscope;
  MagnetometerEvent? magnetometer;

  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? magnetometerSubscription;

  Position? position;
  bool deadReckoningMode = false;
  bool gnssAvailable = false;
  Timer? gnssTimer;
  DateTime? lastGnssUpdate;

  double velocity = 0.0;
  double distanceTravelled = 0.0;
  double acceleration = 0.0;
  double filteredAcceleration = 0.0;
  double accelerationBias = 0.0;
  bool calibrated = false;
  DateTime? lastSensorUpdate;
  Timer? simulationTimer;

  double simulatedLatitude = 37.42200;
  double simulatedLongitude = -122.08400;
  double simulatedSpeed = 42.0;
  double simulatedHeading = 127.0;

  void startDeadReckoningSimulation() {
    simulationTimer?.cancel();

    simulationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!deadReckoningMode) {
          timer.cancel();
          return;
        }

        const double earthRadius = 6371000.0;

        final distance =
            simulatedSpeed / 3.6; // metres travelled in 1 second

        final headingRadians =
            simulatedHeading * 3.141592653589793 / 180.0;

        final deltaLat =
            (distance * cos(headingRadians)) / earthRadius;

        final deltaLon =
            (distance * sin(headingRadians)) /
                (earthRadius *
                    cos(simulatedLatitude * 3.141592653589793 / 180.0));

        setState(() {
          simulatedLatitude += deltaLat * 180.0 / 3.141592653589793;
          simulatedLongitude += deltaLon * 180.0 / 3.141592653589793;
        });
      },
    );
  }

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream().listen((Position newPosition) {
      // Ignore GNSS updates while Dead Reckoning is active.
      if (deadReckoningMode) {
        return;
      }

      setState(() {
        position = newPosition;
        lastGnssUpdate = DateTime.now();
        gnssAvailable = true;

        simulatedLatitude = newPosition.latitude;
        simulatedLongitude = newPosition.longitude;
      });
    });

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();

    accelerometerSubscription =
        accelerometerEventStream().listen((event) {
          accelerometer = event;
        });
    magnetometerEventStream().listen((event) {
      setState(() {
        magnetometer = event;
      });
    });

    gyroscopeEventStream().listen((event) {
      setState(() {
        gyroscope = event;
      });
    });
    gnssTimer = Timer.periodic(
  const Duration(seconds: 5),
  (timer) {
    if (deadReckoningMode) {
      setState(() {
        gnssAvailable = false;
      });
      return;
    }

    // Keep GNSS available after manual restoration.
    // Real GNSS updates will replace the simulated position
    // when a valid Position is received.
  },
);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NavRescue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 9,
                  color: Colors.green,
                ),
                SizedBox(width: 6),
                Text(
                  'SYSTEM READY',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Navigation mode
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.25),
                      Colors.blue.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.4),
                  ),
                ),
                child:  Row(
                  children: [
                    Icon(
                      Icons.navigation,
                      color: Colors.blue,
                      size: 34,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NAVIGATION MODE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            deadReckoningMode ? 'Dead Reckoning' : 'GNSS Navigation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.satellite_alt,
                      color: Colors.green,
                      size: 28,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Map placeholder
              Container(
                height: 220,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF151F30),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: OfflineMapPainter(
                        distanceTravelled: distanceTravelled,
                      ),
                    ),

                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deadReckoningMode ? 'DEAD RECKONING' : 'GNSS NAVIGATION',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          deadReckoningMode
                              ? 'DEAD RECKONING'
                              : 'GNSS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: deadReckoningMode
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double progress =
                              (distanceTravelled % 180) / 180;

                          final double x =
                              80 + progress * (constraints.maxWidth - 160);

                          final double y =
                              constraints.maxHeight * 0.55;

                          return Stack(
                            children: [
                              Positioned(
                                left: x - 21,
                                top: y - 21,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 42,
                                  color: deadReckoningMode
                                      ? Colors.orange
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'LIVE NAVIGATION DATA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 10),

              // Data cards
              Row(
                children: [
                  Expanded(
                    child: _dataCard(
                      icon: Icons.speed,
                      title: 'SPEED',
                      value: deadReckoningMode
                          ? simulatedSpeed.toStringAsFixed(1)
                          : '42',
                      unit: 'km/h',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dataCard(
                      icon: Icons.explore,
                      title: 'HEADING',
                      value: '127°',
                      unit: 'SE',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _dataCard(
                      icon: Icons.satellite_alt,
                      title: 'GNSS',
                      value: gnssAvailable ? 'GOOD' : 'LOST',
                      unit: '8 satellites',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dataCard(
                      icon: Icons.my_location,
                      title: 'POSITION',
                      value: deadReckoningMode
    ? '${simulatedLatitude.toStringAsFixed(5)}, ${simulatedLongitude.toStringAsFixed(5)}'
    : position != null
    ? '${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}'
    : gnssAvailable
    ? '${simulatedLatitude.toStringAsFixed(5)}, ${simulatedLongitude.toStringAsFixed(5)}'
    : 'NO FIX',
                      unit: deadReckoningMode ? 'DEAD RECKONING' : 'GNSS',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Sensor status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F30),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SENSOR STATUS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _sensorRow(
                      Icons.speed,
                      'Accelerometer',
                      accelerometer == null
                          ? 'Waiting...'
                          : '${accelerometer!.x.toStringAsFixed(2)}, '
                          '${accelerometer!.y.toStringAsFixed(2)}, '
                          '${accelerometer!.z.toStringAsFixed(2)}',
                    ),

                    _sensorRow(
                      Icons.rotate_right,
                      'Gyroscope',
                      gyroscope == null
                          ? 'Waiting...'
                          : '${gyroscope!.x.toStringAsFixed(2)}, ${gyroscope!.y.toStringAsFixed(2)}, ${gyroscope!.z.toStringAsFixed(2)}',
                    ),

                    _sensorRow(
                      Icons.explore,
                      'Magnetometer',
                      magnetometer == null
                          ? 'Waiting...'
                          : '${magnetometer!.x.toStringAsFixed(2)}, ${magnetometer!.y.toStringAsFixed(2)}, ${magnetometer!.z.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      deadReckoningMode = !deadReckoningMode;
                      gnssAvailable = !deadReckoningMode;
                    });

                    if (deadReckoningMode) {
                      startDeadReckoningSimulation();
                    } else {
                      simulationTimer?.cancel();
                    }
                  },
                  child: Text(
                    deadReckoningMode
                        ? 'RESTORE GNSS'
                        : 'SIMULATE GNSS OUTAGE',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Dead reckoning status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sync,
                      color: Colors.orange,
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEAD RECKONING ENGINE',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            deadReckoningMode
                                ? 'ACTIVE — GNSS unavailable'
                                : 'Standby — GNSS available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'AI-ML Intelligent Dead Reckoning',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dataCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151F30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sensorRow(
      IconData icon,
      String name,
      String status,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
class OfflineMapPainter extends CustomPainter {
  final double distanceTravelled;

  OfflineMapPainter({
    required this.distanceTravelled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint background = Paint()
      ..color = const Color(0xFF101827);

    final Paint road = Paint()
      ..color = const Color(0xFF3A4658)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint roadLine = Paint()
      ..color = const Color(0xFF697588)
      ..strokeWidth = 2;

    final Paint sideRoad = Paint()
      ..color = const Color(0xFF283446)
      ..strokeWidth = 12;

    final Paint buildings = Paint()
      ..color = const Color(0xFF202C3D);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      background,
    );

    // Main road
    // Main road
    final Path mainRoad = Path();

    mainRoad.moveTo(
      -20,
      size.height * 0.72,
    );

    mainRoad.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.58,
      size.width * 0.55,
      size.height * 0.52,
    );

    mainRoad.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.46,
      size.width + 20,
      size.height * 0.25,
    );

    canvas.drawPath(mainRoad, road);
    canvas.drawPath(mainRoad, roadLine);

    // Side roads
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.63),
      Offset(size.width * 0.12, size.height * 0.15),
      sideRoad,
    );

    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.53),
      Offset(size.width * 0.45, size.height * 0.05),
      sideRoad,
    );

    canvas.drawLine(
      Offset(size.width * 0.70, size.height * 0.43),
      Offset(size.width * 0.92, size.height * 0.65),
      sideRoad,
    );

    // Buildings
    canvas.drawRect(
      Rect.fromLTWH(18, 25, 55, 32),
      buildings,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.30,
        20,
        60,
        35,
      ),
      buildings,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.73,
        size.height * 0.63,
        70,
        35,
      ),
      buildings,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.78,
        size.height * 0.08,
        55,
        30,
      ),
      buildings,
    );

    // Direction arrow
    final Paint direction = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width - 45, size.height - 35),
      Offset(size.width - 45, size.height - 65),
      direction,
    );

    canvas.drawLine(
      Offset(size.width - 45, size.height - 65),
      Offset(size.width - 50, size.height - 57),
      direction,
    );

    canvas.drawLine(
      Offset(size.width - 45, size.height - 65),
      Offset(size.width - 40, size.height - 57),
      direction,
    );
  }

  @override
  bool shouldRepaint(covariant OfflineMapPainter oldDelegate) {
    return oldDelegate.distanceTravelled != distanceTravelled;
  }
}