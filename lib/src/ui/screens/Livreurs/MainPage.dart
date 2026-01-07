import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

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

  // NEW: State for the real address
  String _currentAddress = "Localisation en cours...";
  double _userLatitude = 0;
  double _userLongitude = 0;

  static const _mapboxAccessToken = "pk.eyJ1Ijoia2FiYWRlbGl2ZXJ5IiwiYSI6ImNtaDk4dXhveTBiMzQya3NoaTRnNTVqcjcifQ.qxZKDptlhWj_XxGQeMjgQw";

  @override
  void initState() {
    super.initState();
    _initMapbox();
    _initLocation();
  }

  void _initMapbox() {
    mapbox.MapboxOptions.setAccessToken(_mapboxAccessToken);
  }

  // NEW: Function to get Address from Coordinates
  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );

      final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        // Pick the most relevant part of the address
        String readableAddress = address['road'] ??
            address['suburb'] ??
            address['city'] ??
            data['display_name'];

        setState(() {
          _currentAddress = readableAddress;
        });
      }
    } catch (e) {
      setState(() => _currentAddress = "Lomé, Togo");
    }
  }

  Future<void> _initLocation() async {
    await Permission.locationWhenInUse.request();
    if (await Permission.locationWhenInUse.isGranted) {
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        _userPoint = mapbox.Point(
          coordinates: mapbox.Position(position.longitude, position.latitude),
        );
      });

      // CALL ADDRESS FETCH HERE
      await _getAddressFromLatLng(_userLatitude, _userLongitude);

      if (_mapboxMap != null) {
        await _mapboxMap!.setCamera(
          mapbox.CameraOptions(center: _userPoint, zoom: 15.0),
        );
        await _mapboxMap!.location.updateSettings(
          mapbox.LocationComponentSettings(enabled: true, pulsingEnabled: true),
        );
      }
    }
  }

  void _onMapCreated(mapbox.MapboxMap controller) {
    setState(() => _mapboxMap = controller);
    if (_userPoint != null) {
      _mapboxMap!.setCamera(mapbox.CameraOptions(center: _userPoint, zoom: 15.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mapbox.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: "mapbox://styles/kabadelivery/cmh98wmrc000901pgguvnfczk",
          ),
          const _Header(),
          _BottomSheet(
            address: _currentAddress, // Pass the dynamic address
            lat: _userLatitude,
            lon: _userLongitude,
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String address;
  final double lat;
  final double lon;

  const _BottomSheet({
    required this.address,
    required this.lat,
    required this.lon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address+" ( "  + lon.toString()  + lat.toString() +" ) ", // Displays real address
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.edit, color: Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            _LivreurTile(),
            const SizedBox(height: 16),
            const Row(
              children: [
                _InfoCard("5", "Livreurs disponibles"),
                SizedBox(width: 12),
                _InfoCard("3 min", "Un livreur arrive"),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD61C4E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // UNCOMMENTED and passed real data to next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryConfigurationPage(
                       pickupAddress: address,
                        latitude: lat,
                        longitude: lon,
                      ),
                    ),
                  );
                },
                child: const Text("Demander un livreur maintenant", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Livreur Tile for clean code
class _LivreurTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.delivery_dining, color: Colors.white)),
          SizedBox(width: 12),
          Expanded(child: Text("Livreur le plus proche\nKoffi M. • 0.8 km ⭐ 4.9")),
          Text("3 min"),
        ],
      ),
    );
  }
}



class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoCard(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Un livreur quand\nvous voulez !",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _pill(Icons.flash_on, "4.7/5"),
                const SizedBox(width: 8),
                const Icon(Icons.call, color: Colors.white),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeaderBadge(
                  "Suivi",
                  3,
                  Icons.trending_up,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LiveTrackingPage()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _HeaderBadge(
                  "Portefeuille",
                  2,
                  Icons.account_balance_wallet,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletPage()),
                    );
                    print("Portefeuille clicked");
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderBadge(
      this.label,
      this.count,
      this.icon, {
        required this.onTap,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD61C4E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


