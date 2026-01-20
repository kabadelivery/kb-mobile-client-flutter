import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../customwidgets/BesoinLivreurs/PerformanceModal.dart';
import 'ConfigurationPage.dart';
import 'Suivis_direct.dart';
import 'Transactions/Dashboard.dart';

class UserLocationMap extends StatefulWidget {
  const UserLocationMap({super.key});

  @override
  State<UserLocationMap> createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  mapbox.MapboxMap? _mapboxMap;
  mapbox.Point? _userPoint;

  String _currentAddress = "Localisation en cours...";
  double _userLatitude = 0;
  double _userLongitude = 0;

  // -1: Loading, 0: No drivers found, >0: Drivers found
  int _livreursCount = -1;
  String _nomProche = "";
  double _distProche = 0.0;
  int _tempsEstime = 0;

  StreamSubscription? _livreursSubscription;
  Timer? _fetchTimer;

  static const _mapboxAccessToken = "pk.eyJ1Ijoia2FiYWRlbGl2ZXJ5IiwiYSI6ImNtaDk4dXhveTBiMzQya3NoaTRnNTVqcjcifQ.qxZKDptlhWj_XxGQeMjgQw";

  @override
  void initState() {
    super.initState();
    _initMapbox();
    _initLocation();
  }

  @override
  void dispose() {
    _livreursSubscription?.cancel();
    _fetchTimer?.cancel();
    super.dispose();
  }

  void _initMapbox() {
    mapbox.MapboxOptions.setAccessToken(_mapboxAccessToken);
  }

  // This timer ensures the loading circle doesn't spin forever
  void _startSafetyTimer() {
    _fetchTimer?.cancel();
    _fetchTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _livreursCount == -1) {
        // If still loading after 10s, we assume no drivers were found or fetch failed
        setState(() => _livreursCount = 0);
      }
    });
  }

  Future<void> _initLocation() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        if (mounted) {
          setState(() {
            _userLatitude = position.latitude;
            _userLongitude = position.longitude;
            _userPoint = mapbox.Point(coordinates: mapbox.Position(position.longitude, position.latitude));
          });
        }

        await _getAddressFromLatLng(position.latitude, position.longitude);
        _startListeningToLivreurs();
        _startSafetyTimer(); // Start the 10s limit here

        if (_mapboxMap != null && _userPoint != null) {
          _mapboxMap!.setCamera(mapbox.CameraOptions(center: _userPoint, zoom: 15.0));
          _mapboxMap!.location.updateSettings(mapbox.LocationComponentSettings(enabled: true, pulsingEnabled: true));
        }
      } catch (e) {
        if (mounted) setState(() => _livreursCount = 0);
      }
    } else {
      if (mounted) setState(() => _livreursCount = 0);
    }
  }

  void _startListeningToLivreurs() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('livreurs');
    _livreursSubscription = ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null || data.isEmpty) {
        if (mounted) setState(() => _livreursCount = 0);
        return;
      }

      int count = 0;
      double minDistance = double.infinity;
      String nearestName = "";

      data.forEach((key, value) {
        if (value['current_location'] != null) {
          count++;
          double lLat = value['current_location']['lat'];
          double lLon = value['current_location']['lon'];

          double distance = Geolocator.distanceBetween(_userLatitude, _userLongitude, lLat, lLon);

          if (distance < minDistance) {
            minDistance = distance;
            nearestName = value['nom'] ?? "Livreur";
          }
        }
      });

      if (mounted) {
        setState(() {
          _livreursCount = count;
          _distProche = minDistance / 1000;
          _nomProche = nearestName;
          _tempsEstime = (_distProche * 3).round() + 2;
        });
        _fetchTimer?.cancel(); // Success! Stop the timer.
      }
    });
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'Kaba_Delivery_Lome'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final a = data['address'];
        String road = a['road'] ?? a['pedestrian'] ?? a['suburb'] ?? a['neighbourhood'] ?? "";
        String city = a['city'] ?? a['town'] ?? a['village'] ?? "Lomé";

        if (mounted) {
          setState(() => _currentAddress = road.isNotEmpty ? "$road, $city" : city);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "Lomé, Togo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mapbox.MapWidget(
            onMapCreated: (c) => _mapboxMap = c,
            styleUri: "mapbox://styles/kabadelivery/cmh98wmrc000901pgguvnfczk",
          ),
          const _Header(),
          _BottomSheet(
            address: _currentAddress,
            lat: _userLatitude, lon: _userLongitude,
            nbLivreurs: _livreursCount,
            nomLivreur: _nomProche,
            distance: _distProche, temps: _tempsEstime,
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String address, nomLivreur;
  final double lat, lon, distance;
  final int nbLivreurs, temps;

  const _BottomSheet({
    required this.address, required this.lat, required this.lon,
    required this.nbLivreurs, required this.nomLivreur,
    required this.distance, required this.temps,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    Widget? cards;
    String btnText = "Demander un livreur maintenant";

    if (nbLivreurs == -1) {
      // 1. LOADING
      content = const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator(color: Color(0xFFD61C4E))));
    } else if (nbLivreurs <= 0) {
      // 2. NO DATA OR TIMEOUT
      btnText = "Faire une demande en attendant";
      content = Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.2))),
        child: const Row(children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(child: Text("Aucun livreur disponible dans votre zone pour le moment", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
        ]),
      );
    } else {
      // 3. SUCCESS
      content = _LivreurTile(nom: nomLivreur, dist: distance, temps: temps);
      cards = Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Row(children: [
          _InfoCard(nbLivreurs.toString(), "Livreurs disponibles"),
          const SizedBox(width: 10),
          _InfoCard("$temps min", "Temps d'arrivée"),
        ]),
      );
    }

    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text("Adresse de départ", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.location_on, color: Color(0xFFD61C4E), size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.edit, color: Colors.grey, size: 18),
            ]),
            const SizedBox(height: 20),
            content,
            if (cards != null) cards,
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD61C4E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DeliveryConfigurationPage(pickupAddress: address, latitude: lat, longitude: lon))),
                child: Text(btnText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... helper widgets (_LivreurTile, _InfoCard, _Header) remain as previously defined.

// --- SUPPORTING UI WIDGETS ---

class _LivreurTile extends StatelessWidget {
  final String nom; final double dist; final int temps;
  const _LivreurTile({required this.nom, required this.dist, required this.temps});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        const CircleAvatar(backgroundColor: Color(0xFFD61C4E), child: Icon(Icons.delivery_dining, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Text("Livreur le plus proche: $nom\n${dist.toStringAsFixed(1)} km ⭐ 4.9", style: const TextStyle(fontSize: 13, height: 1.4))),
        Text("$temps min", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD61C4E))),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title; final String subtitle;
  const _InfoCard(this.title, this.subtitle);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFD61C4E).withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD61C4E))),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // This takes the user back
            },
          ),
            const SizedBox(width: 12),
            const Expanded(child: Text("Un livreur quand\nvous voulez !", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            _pill(Icons.flash_on, "4.7/5", () {
              showDialog(
                context: context,
                barrierDismissible: true, // Allows tapping outside to close
                builder: (BuildContext context) {
                  return const PerformanceCard(
                    initialRating: 4.7,
                    totalReviews: 120,
                  );
                },
              );
              // Add your navigation or logic here
            }),
            const SizedBox(width: 8),
            const Icon(Icons.call, color: Colors.white),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _HeaderBadge("Suivi", 0, Icons.trending_up, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LiveTrackingPage()))),
            const SizedBox(width: 12),
            _HeaderBadge("Portefeuille", 0, Icons.account_balance_wallet, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletPage(userId: 36572)))),
          ])
        ]),
      ),
    );
  }

  Widget _pill(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // The function to run when clicked
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prevents row from taking full width
          children: [
            Icon(icon, color: Colors.yellow, size: 16),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label; final int count; final IconData icon; final VoidCallback onTap;
  const _HeaderBadge(this.label, this.count, this.icon, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 6),
            CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Text("$count", style: const TextStyle(fontSize: 12, color: Color(0xFFD61C4E), fontWeight: FontWeight.bold))),
          ]),
        ),
      ),
    );
  }
}