import 'dart:async';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/_static_data/KTheme.dart';

class GoogleMapsPage extends StatefulWidget {
  static var routeName = "/GoogleMapsPage";

  GoogleMapsPage({Key key}) : super(key: key);

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.221316, 1.188478),
    zoom: 14.4746,
  );

  static final CameraPosition _goToMyPosition = CameraPosition(
      bearing: 192.8334901395799, target: LatLng(6.196444, 1.201095), zoom: 18);

  var geolocator = Geolocator();
  var locationOptions =
      LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

  StreamSubscription<Position> positionStream;

  Position _myPosition;

  @override
  void initState() {
    super.initState();

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions).listen(
      (Position position) {
        _onPositionChanged(position);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Card(
          child: InkWell(
              child: IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: KColors.new_black,
                  ),
                  onPressed: () => _goToMe()))),
    );
  }

  Future<void> _goToMe() async {
    if (_myPosition == null) {
      _myPosition = await Geolocator.getLastKnownPosition();
    }
    final GoogleMapController controller = await _controller.future;
    if (_myPosition != null)
      controller.animateCamera(_getCamerationPosition(_myPosition));
  }

  _onPositionChanged(Position position) {
    this._myPosition = position;
    xrint(position == null
        ? 'Unknown'
        : position.latitude.toString() + ', ' + position.longitude.toString());
  }

  _getCamerationPosition(Position position) {
    return CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(position.latitude, position.longitude),
        zoom: 18);
  }
}
