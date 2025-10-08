import 'package:geocoding/geocoding.dart';

Future<String> getPlaceNameFromCoords(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.name}, ${place.locality}";
    } else {
      return "Localisation";
    }
  } catch (e) {
    return "Error: $e";
  }
}