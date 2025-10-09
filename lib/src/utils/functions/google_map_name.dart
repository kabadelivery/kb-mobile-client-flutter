import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCache {
  static LatLng? lastLatLng;
  static String? lastPlaceName;
}

Future<String> getPlaceNameFromCoords(double lat, double lng) async {
  final apiKey = AppConfig.GOOGLE_MAP_API_KEY;
  final current = LatLng(lat, lng);
  if (LocationCache.lastPlaceName != null) {
    final name = LocationCache.lastPlaceName!;
    debugPrint("✅ Using cached nearby place: $name");

    LocationCache.lastLatLng = null;
    LocationCache.lastPlaceName = null;

    return name;
  }

  try {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return "Error: ${response.statusCode}";
    }

    final data = json.decode(response.body);
    final results = data['results'] as List;
    if (results.isEmpty) return "Unknown location";

    final first = results.first;
    final placeName = first['formatted_address'] ?? "Unknown location";

    debugPrint("📍 Geocoded new place: $placeName");
    return placeName;
  } catch (e) {
    return "Error: $e";
  }
}

void updateNearbyPlaceCache(LatLng latLng, String name) {
  LocationCache.lastLatLng = latLng;
  LocationCache.lastPlaceName = name;
  debugPrint("💾 Saved nearby place: $name");
}
