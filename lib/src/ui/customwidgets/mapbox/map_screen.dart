import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class UserLocationMap extends StatefulWidget {
  const UserLocationMap({super.key});

  @override
  State<UserLocationMap> createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  mapbox.MapboxMap? _mapboxMap;
  mapbox.Point? _userPoint;
  final TextEditingController _searchController = TextEditingController();
  late Position position ;
  static const _mapboxAccessToken ="";
  double _userLatitude = 0;
  double _userLongitude = 0;
  mapbox.PointAnnotationManager? _pointAnnotationManager;
  @override
  void initState() {
    super.initState();
    _initMapbox();
    _initLocation();
  }
  Future<void> _addMarker(double lat, double lon) async {
    if (_mapboxMap == null) return;

    // Create manager only once
    _pointAnnotationManager ??= await _mapboxMap!.annotations.createPointAnnotationManager();

    // Remove previous markers if you want only one
    _pointAnnotationManager!.deleteAll();

    // Create marker using PointAnnotationOptions
    final pointAnnotationOptions = mapbox.PointAnnotationOptions(
      geometry: mapbox.Point(coordinates: mapbox.Position(lon, lat)),
      iconImage: "marker-15", // default Mapbox icon
      iconSize: 1.5, // optional
    );

    _pointAnnotationManager!.create(pointAnnotationOptions);

    setState(() {
      _userLatitude = lat;
      _userLongitude = lon;
    });
  }
  void _initMapbox() {
    mapbox.MapboxOptions.setAccessToken(_mapboxAccessToken);
  }

  Future<void> _initLocation() async {
    await Permission.locationWhenInUse.request();
    position = await Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).first;
    if (await Permission.locationWhenInUse.isGranted) {
      Position position = await Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).first;
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
        _userPoint = mapbox.Point(
          coordinates: mapbox.Position(position.longitude, position.latitude),
        );
      });

      // Once we have both map and location, update the camera
      if (_mapboxMap != null) {

        await _mapboxMap!.setCamera(
          mapbox.CameraOptions(
            center: _userPoint,
            zoom: 15.0,
          ),
        );

        setState(() {
          _userLatitude = position.latitude;
          _userLongitude = position.longitude;
        });
        // Enable user location puck
        await _mapboxMap!.location.updateSettings(
          mapbox.LocationComponentSettings(
            enabled: true,
            pulsingEnabled: true,
          ),
        );
      }
    } else {
      // Request permission again or show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
    }
  }

  void _onMapCreated(mapbox.MapboxMap controller) {
    setState(() => _mapboxMap = controller);
    // as soon as map is ready, try to center on user
    if (_userPoint != null) {
      _mapboxMap!.setCamera(
        mapbox.CameraOptions(
          center: _userPoint,
          zoom: 15.0,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchNominatimSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=tg'
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      debugPrint("Data map : $data");
      return data.map((item) {
        return {
          'name': item['display_name'],
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        };
      }).toList();
    } else {
      return [];
    }
  }

  /// Fetch location suggestions from Mapbox Geocoding API
  Future<List<Map<String, dynamic>>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json"
        "?access_token=$_mapboxAccessToken"
        '&country=TG'
        "&autocomplete=true"
        '&proximity=$_userLatitude,$_userLongitude'
        "&limit=5";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List<dynamic>;
      return features
          .map((f) => {
        'place': f['place_name'],
        'lat': f['center'][1],
        'lon': f['center'][0],
      })
          .toList();
    } else {
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Localisation")),
      body: Stack(
        children: [
          mapbox.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: "mapbox://styles/kabadelivery/cmh98wmrc000901pgguvnfczk",
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: fetchNominatimSuggestions,
                builder: (context, controller, focusNode) {
                  // Tu peux stocker le controller si besoin
                  _searchController.value = controller.value;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: "Search location...",
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  );
                },
                itemBuilder: (context, suggestion) {
                  final name = suggestion['name'] ?? suggestion['display_name'] ?? "Lieu inconnu";
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(name),
                  );
                },
                onSelected: (suggestion) async {
                  debugPrint("Suggestion: $suggestion");
                  final lat = suggestion['lat'];
                  final lon = suggestion['lon'];

                  if (lat != null && lon != null) {
                    await _mapboxMap?.setCamera(
                      mapbox.CameraOptions(
                        center: mapbox.Point(coordinates: mapbox.Position(lon, lat)),
                        zoom: 25.0,
                      ),
                    );
                  }
                  _searchController.text = suggestion['name'] ?? suggestion['display_name'] ?? '';
                },
                loadingBuilder: (context) => const ListTile(title: Text("Loading...")),
                emptyBuilder: (context) => const ListTile(title: Text("No results found")),
                hideOnEmpty: true,
                hideOnLoading: true,
                offset: const Offset(0, 12),
                decorationBuilder: (context, child) => Material(
                  type: MaterialType.card,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
