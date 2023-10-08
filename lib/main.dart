import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoDrive',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int points = 0;
  int aggressiveEvents = 0;
  // Your additional metrics
  double distanceCovered = 0.0; // Example distance in km
  double fuelSaved = 0.0; // Example fuel saved in liters
  double co2Reduced = 0.0; // Example CO2 reduced in kg
  double treesEquivalent = 0.0; // Example trees saved in number

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _pointTimer;

  void startDrive() {
    _startMonitoringAggressiveEvents();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DriveFeedbackScreen(parentState: this)),
    );
  }

  void _startMonitoringAggressiveEvents() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x > 2.0 || event.x < -2.0) {
        setState(() {
          aggressiveEvents++;
          points -= 3;
        });
      }
    });

    _pointTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        if (aggressiveEvents == 0) {
          points += 5;

          // Update other metrics
          distanceCovered += 0.5;  // Assume 0.5 km covered every 10 seconds
          fuelSaved += 0.01;  // Assume 0.01 liters of fuel saved every 10 seconds of smooth driving
          co2Reduced = fuelSaved * 2.3;  // 2.3 kg of CO2 produced per liter of gasoline
          treesEquivalent = co2Reduced / 22;  // 22 kg of CO2 absorbed by a tree per year
        }
        aggressiveEvents = 0;
      });
    });
  }

  void stopRide() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _pointTimer?.cancel();
    _pointTimer = null;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Total Points Accumulated:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('$points', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: Colors.green)),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(Icons.assistant_navigation, size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text('Distance: ${distanceCovered.toStringAsFixed(2)} km', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_gas_station, size: 40, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Fuel Saved: ${fuelSaved.toStringAsFixed(2)}L', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Icon(Icons.eco, size: 40, color: Colors.green),
                    SizedBox(height: 8),
                    Text('CO2 Reduced: ${co2Reduced.toStringAsFixed(2)}kg', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.nature, size: 40, color: Colors.brown),
                    SizedBox(height: 8),
                    Text('Trees Planted: ${treesEquivalent.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.drive_eta),
              label: Text('Start New Ride'),
              onPressed: startDrive,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriveFeedbackScreen extends StatefulWidget {
  final _DashboardState parentState;

  DriveFeedbackScreen({required this.parentState});

  @override
  _DriveFeedbackScreenState createState() => _DriveFeedbackScreenState();
}

class _DriveFeedbackScreenState extends State<DriveFeedbackScreen> {
  late Timer _timer;
  Duration _duration = Duration();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration += Duration(seconds: 1);
      });
    });
  }

  void _stopTimerAndNavigate() {
    _timer.cancel();
    widget.parentState.stopRide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drive Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Elapsed Time:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
              SizedBox(height: 30),
              Text('Acceleration/Braking Events:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('${widget.parentState.aggressiveEvents}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.red)),
              SizedBox(height: 30),
              Text('Total points earned:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('${widget.parentState.points}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: Colors.green)),
              SizedBox(height: 30),
              Text('Tips:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Maintain a consistent speed to earn more points!', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text('Avoid accelerating/braking abruptly', style: TextStyle(fontSize: 20)),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.stop),
                label: Text('Stop Ride'),
                onPressed: _stopTimerAndNavigate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
