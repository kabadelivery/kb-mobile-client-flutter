import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: DeliveryTrackingPage(),
));

class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({super.key});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  // State variables
  int _estimatedMinutes = 5;
  String _status = "Livreur en approche";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a simple countdown timer to demonstrate statefulness
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_estimatedMinutes > 1) {
        setState(() {
          _estimatedMinutes--;
        });
      } else {
        setState(() {
          _status = "Livreur est arrivé !";
          _estimatedMinutes = 0;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Grid Layer
          Container(
            color: const Color(0xFFE0F7F4),
            child: CustomPaint(
              painter: GridPainter(),
              child: Container(),
            ),
          ),

          // 2. Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFD31D44),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suivi en direct',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _status, // Dynamic state variable
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Markers
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                // Driver Marker (In a real app, position this with coordinates)
                const Icon(Icons.location_on, size: 50, color: Color(0xFFD31D44)),
              ],
            ),
          ),

          // 4. Information Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text(
                            'Livreur en route',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const Text('4 000 FCFA', style: TextStyle(color: Color(0xFFD31D44), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const RouteTimeline(label: 'Départ', location: 'Tokoin, Lomé', color: Colors.blue),
                  const RouteTimeline(label: 'Arrivée', location: 'Agoè, Lomé', color: Colors.green, isLast: true),

                  const SizedBox(height: 20),

                  // Driver Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                            radius: 22
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Livreur Koffi M.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('+228 90 12 34 56', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.phone_in_talk_outlined, color: Colors.grey[400]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Estimated Arrival
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE8F5FD),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.blue, size: 30),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Temps estimé', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text(
                                '$_estimatedMinutes min', // Updated by state
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Timeline Component
class RouteTimeline extends StatelessWidget {
  final String label;
  final String location;
  final Color color;
  final bool isLast;

  const RouteTimeline({super.key, required this.label, required this.location, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              if (!isLast) Expanded(child: VerticalDivider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              Text(location, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (!isLast) const SizedBox(height: 15),
            ],
          )
        ],
      ),
    );
  }
}