import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/recustomlib/place_picker.dart' as Pp;
import 'package:android_intent/android_intent.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lo;
import 'package:toast/toast.dart';


class EditAddressPage extends StatefulWidget {

  static var routeName = "/EditAddressPage";

  DeliveryAddressModel address;

  EditAddressPresenter presenter;

  CustomerModel customer;

  DeliveryAddressModel createdAddress = null;

  EditAddressPage({Key key, this.address, this.presenter}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState(address);
}

class _EditAddressPageState extends State<EditAddressPage> implements EditAddressView {

//  String apiKey = "AIzaSyDttW16iZe-bhdBIQZFHYii3mdkH1-BsWs";

  LatLng selectedLocation;
  DeliveryAddressModel address;

  var _locationNameController = TextEditingController(), _phoneNumberController = TextEditingController(),
      _nearController = TextEditingController(), _descriptionController = TextEditingController();

  bool _checkLocationLoading = false;
  bool _isUpdateOrCreateAddressLoading = false;

  _EditAddressPageState(this.address) {
    if (address != null && address.location != null) {
      String latitude =  address.location.split(":")[0];
      String longitude =  address.location.split(":")[1];
      selectedLocation = LatLng(double.parse(latitude), double.parse(longitude));
    }
    if (address == null) {
      address = DeliveryAddressModel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.editAddressView = this;
    widget.address = address;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      _getLastKnowLocation();
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("${AppLocalizations.of(context).translate('edit_address')}", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              /* boxes to show the pictures selected. */
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _locationNameController, minLines: 2, maxLines: 5, style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate('location_name')}",
                      hintMaxLines: 5,
                      border: InputBorder.none,
                    ))..controller.text=address?.name,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _phoneNumberController, maxLength: 8, keyboardType: TextInputType.phone, minLines: 2, maxLines: 5, style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate('phone_number')}",
                      border: InputBorder.none,
                      hintMaxLines: 5,
                    ))..controller.text=address?.phone_number,
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.white.withAlpha(200),
                child: InkWell(splashColor: Colors.red,
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          !_checkLocationLoading && address?.location != null ?
                          Text("${AppLocalizations.of(context).translate('choose_location')}", style: TextStyle(color: KColors.primaryColor, fontSize: 16)) :
                          BouncingWidget(
                            duration: Duration(milliseconds: 400),
                            scaleFactor: 2,
                            child: Text("${AppLocalizations.of(context).translate('choose_location')}", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top:10, bottom:10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
//                                  isPickLocation
                                  isPickLocation ? SizedBox(height: 15, width: 15,child: Center(child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation<Color>(Colors.green)))) : Container(),
                                  _checkLocationLoading ? SizedBox(height: 15, width: 15,child: Center(child: CircularProgressIndicator(strokeWidth: 2))) : Container(),
                                  !_checkLocationLoading && address?.location != null ? Icon(Icons.check_circle, color: KColors.primaryColor) : Container(),
                                  SizedBox(width: 10),
                                  !_checkLocationLoading && address?.location != null ? Icon(Icons.chevron_right, color: KColors.primaryColor) :
                                  BouncingWidget(
                                    duration: Duration(milliseconds: 300),
                                    scaleFactor: 2,
                                    child: Icon(Icons.chevron_right, color: KColors.primaryColor),
                                  ),
                                ]),
                          )],
                      )),onTap: () => showPlacePicker(context),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _nearController,minLines: 2, maxLines: 5, style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate('not_far_from')}",
                      border: InputBorder.none,
                    ))..controller.text=address?.near,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(controller: _descriptionController, minLines: 2, maxLines: 5, style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(labelText: "${AppLocalizations.of(context).translate('address_details')}",
                      border: InputBorder.none,
                    ))..controller.text=address?.description,
              ),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(padding: EdgeInsets.only(top:10, bottom: 10, left:5, right:5), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Row(
                    children: <Widget>[
                      Text("${AppLocalizations.of(context).translate('confirm')}", style: TextStyle(fontSize: 16, color: Colors.white)),
                      _isUpdateOrCreateAddressLoading ?  Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 15, width: 15) ,
                          SizedBox(width: 5),
                        ],
                      )  : Container(),
                    ],
                  ),color: KColors.primaryColor, onPressed: () => _saveAddress()),
                  SizedBox(width: 10),
                  MaterialButton(padding: EdgeInsets.only(top:10, bottom: 10), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Text("${AppLocalizations.of(context).translate('cancel')}", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),color: Colors.white, onPressed: () => _exit())
                ],
              )
            ]
        ),
      ),
    );
  }

  StreamSubscription<Position> positionStream;

  void showPlacePicker (BuildContext context) async {

    /* get last know position */
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else if (permission == LocationPermission.denied) {
      Geolocator.requestPermission();
    } else {
        // location is enabled
      bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        await Geolocator.openLocationSettings();
      } else {
          positionStream = Geolocator.getPositionStream().listen(
                (Position position) {
                  /* only once */
                  print("position stream");
                  _jumpToPickAddressPage();
                  positionStream?.cancel();
            });
      }
    }
  }

  bool isPickLocation = false;

  void _jumpToPickAddressPage() async {

//    Location location = Location();
    /*location.getLocation().then((LocationData cLoc) {
//      setState(() {
      print("location : ${cLoc.latitude}:${cLoc.longitude}");
//      });
    }).catchError((onError){
      print(onError);
    });*/

    if (isPickLocation)
      return;

    setState(() {
      isPickLocation = true;
    });

    lo.LocationData location = await lo.Location().getLocation();

    StateContainer.of(context).updateLocation(location: Position(latitude: location.latitude, longitude: location.longitude));

    if (StateContainer.of(context).location != null)
      Pp.PlacePickerState.initialTarget = LatLng(StateContainer.of(context).location.latitude, StateContainer.of(context).location.longitude);

    print("i pick address");

    /* get my position */
    LatLng result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            Pp.PlacePicker(AppConfig.GOOGLE_MAP_API_KEY)));
    /* use this location to generate details about the place the user lives and so on. */

    setState(() {
      isPickLocation = false;
    });

    if (result != null) {
      /*  */
      setState(() {
        _checkLocationLoading = true;
        address.location = "${result.latitude}:${result.longitude}";
      });
      print(address.location);
      // use mvp to launch a request and place the result here.
      widget.presenter.checkLocationDetails(widget.customer, position:   Position(longitude: result.longitude, latitude: result.latitude));
    } else {
      setState(() {
        isPickLocation = false;
      });
    }
  }

  void _exit() {
    Navigator.of(context).pop();
  }

  _saveAddress() {
    address.name = _locationNameController.text;
    address.description = _descriptionController.text;
    address.near = _nearController.text;
    address.phone_number = _phoneNumberController.text;

    widget.presenter.updateOrCreateAddress(address, widget.customer);
  }

  @override
  void addressModificationFailure(String message) {

    /* error. */
    _showDialog(
//      okBackToHome: true,
      icon: VectorsData.address_creation_error,
      message: "${AppLocalizations.of(context).translate('address_modification_failure')}",
      isYesOrNo: false,
    );
  }

  @override
  void createdSuccess(DeliveryAddressModel address) {
    /* created successful */
    widget.createdAddress = address;
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.address_creation_success,
      message: "${AppLocalizations.of(context).translate('address_creation_success')}",
      isYesOrNo: false,
    );
  }

  @override
  void createFailure() {
    /* created failure */
    _showDialog(
      icon: VectorsData.address_creation_error,
      message: "${AppLocalizations.of(context).translate('address_modification_failure')}",
      isYesOrNo: false,
    );
  }

  @override
  void modifiedSuccess() {
    /* modified successful */
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.address_creation_success,
      message: "${AppLocalizations.of(context).translate('address_modification_success')}",
      isYesOrNo: false,
    );
  }



  void _showDialog({var icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /* icon */
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                        icon,
                      )),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              // usually buttons at the bottom of the dialog
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color:Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text("${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color:KColors.primaryColor)),
                onPressed: (){
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text("${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color:KColors.primaryColor)),
                onPressed: () {
                  if (okBackToHome){
                    Navigator.of(context).pop({'ok':true, 'createdAddress': widget.createdAddress});
                    Navigator.of(context).pop({'ok':true, 'createdAddress': widget.createdAddress});
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ]
        );
      },
    );
  }

  @override
  void showLoading(bool isLoading) {

  }

  @override
  void inflateDescription(String description_details, String suburb) {
    showAddressDetailsLoading(false);
    setState(() {
      address.description = description_details;
      _descriptionController.text = description_details;
      address.quartier = suburb;
    });
  }

  @override
  void inflateDetails(String addressDetails) {

  }

  Future _getLastKnowLocation() async {

    /*_checkLocationActivated();
    // save in to state container.
    Position position = await  Geolocator().getLastKnownPosition(desiredAccuracy:  LocationAccuracy.high);*/
//    if (position != null)
//      StateContainer.of(context).updateLocation(location: position);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else if (permission == LocationPermission.denied) {
      Geolocator.requestPermission();
    } else {
      // location is enabled
      bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        await Geolocator.openLocationSettings();
      } else {
        positionStream = Geolocator.getPositionStream().listen(
                (Position position) {
              if (position != null && mounted)
                StateContainer.of(context).updateLocation(location: position);
            });
      }
    }
  }

 /* _checkLocationActivated () async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${AppLocalizations.of(context).translate('cant_get_location')}"),
              content: Text("${AppLocalizations.of(context).translate('please_enable_gps')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text('${AppLocalizations.of(context).translate('ok')}'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }*/


  @override
  void showAddressDetailsLoading(bool isLoading) {
    setState(() {
      _checkLocationLoading = isLoading;
    });
  }

  @override
  void showUpdateOrCreatedAddressLoading(bool isLoading) {
    setState(() {
      _isUpdateOrCreateAddressLoading = isLoading;
    });
  }

  @override
  void checkLocationDetailsError() {

    setState(() {
      address.location = null;
    });
    mToast("${AppLocalizations.of(context).translate('gps_pick_again')}");
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void networkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }


}
