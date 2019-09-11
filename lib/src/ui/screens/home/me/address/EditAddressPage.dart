import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/AppConfig.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/recustomlib/place_picker.dart' as Pp;
import 'package:location_permissions/location_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as prefix0;


class EditAddressPage extends StatefulWidget {

  static var routeName = "/EditAddressPage";

  DeliveryAddressModel address;

  EditAddressPage({Key key, this.address}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState(address);
}

class _EditAddressPageState extends State<EditAddressPage> {

  String apiKey = "AIzaSyDttW16iZe-bhdBIQZFHYii3mdkH1-BsWs";

  LatLng initialCenter = LatLng(6.221316, 1.188478);

  DeliveryAddressModel address;

  var _locationNameController = TextEditingController(), _phoneNumberController = TextEditingController(),
      _nearController = TextEditingController(), _descriptionController = TextEditingController();

  _EditAddressPageState(this.address) {
    if (address != null && address.location != null) {
      String latitude =  address.location.split(":")[0];
      String longitude =  address.location.split(":")[1];
      initialCenter = LatLng(double.parse(latitude), double.parse(longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("EDIT ADDRESS", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              /* boxes to show the pictures selected. */
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _locationNameController,
                    decoration: InputDecoration(labelText: "Name of Location",
                      border: InputBorder.none,
                    ))..controller.text=address?.name,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: "Phone number",
                      border: InputBorder.none,
                    ))..controller.text=address?.phone_number,
              ),
              SizedBox(height: 10),
              InkWell(
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Select Position", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(icon: Icon(Icons.check_circle, color: KColors.primaryColor), onPressed: () {}),
                              SizedBox(width: 10),
                              IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: () {})
                            ])],
                    )),onTap: () => showPlacePicker(context),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _nearController,
                    decoration: InputDecoration(labelText: "Not so far from",
                      border: InputBorder.none,
                    ))..controller.text=address?.near,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _descriptionController, maxLines: 4,
                    decoration: InputDecoration(labelText: "Address Details",
                      border: InputBorder.none,
                    ))..controller.text=address?.description,
              ),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(padding: EdgeInsets.only(top:10, bottom: 10), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Text("CONFIRM", style: TextStyle(fontSize: 16, color: Colors.white)),color: KColors.primaryColor, onPressed: () {}),
                  SizedBox(width: 10),
                  MaterialButton(padding: EdgeInsets.only(top:10, bottom: 10), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Text("CANCEL", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),color: Colors.white, onPressed: () {})
                ],
              )

            ]
        ),
      ),
    );
  }

  /* void showPlacePicker() async {

*//*  LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyDttW16iZe-bhdBIQZFHYii3mdkH1-BsWs")));
    // Handle the result in your way
    print(result);*//*
//   GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();

//    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);

    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();

    if(geolocationStatus != GeolocationStatus.granted) {

      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.location]);

      geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
      if(geolocationStatus != GeolocationStatus.granted) {
        _jumpToMapPage();
      } else {

      }
    } else {
      _jumpToMapPage();
    }
    _jumpToMapPage();
  }*/

  void showPlacePicker (BuildContext context) async {

    /* get last know position */
    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();

    if(geolocationStatus != GeolocationStatus.granted) {
      Map<PermissionGroup, prefix0.PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);
      geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
      if(geolocationStatus != GeolocationStatus.granted) {
        _jumpToPickAddressPage();
      }
    } else {
      _jumpToPickAddressPage();
    }
  }

  void _jumpToPickAddressPage() async {

    /* get my position */
//    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            Pp.PlacePicker(AppConfig.GOOGLE_MAP_API_KEY)));

/* use this location to generate details about the place the user lives and so on. */

//    print(result);

  }

}
