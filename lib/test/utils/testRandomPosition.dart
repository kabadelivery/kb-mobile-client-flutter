import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

Position generateRandomPositionAroundLome() {

  // Position de base
  const double baseLat = 6.126246248639331;
  const double baseLng = 1.2025730490728248;

  final random = Random();

  // ~ +/- 2 km
  const double offset = 0.02;

  final double randomLat =
      baseLat + (random.nextDouble() * 2 - 1) * offset;

  final double randomLng =
      baseLng + (random.nextDouble() * 2 - 1) * offset;
  debugPrint("simulated position ${randomLat}; $randomLng");
  return Position(
    latitude: randomLat,
    longitude: randomLng,
    timestamp: DateTime.now(),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}