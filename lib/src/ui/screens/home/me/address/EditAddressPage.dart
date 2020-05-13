import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/recustomlib/place_picker.dart' as Pp;
import 'package:location/location.dart' as lo;
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';


class EditAddressPage extends StatefulWidget {

  static var routeName = "/EditAddressPage";

  DeliveryAddressModel address;

  EditAddressPresenter presenter;

  CustomerModel customer;

  EditAddressPage({Key key, this.address, this.presenter}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState(address);
}

class _EditAddressPageState extends State<EditAddressPage> implements EditAddressView {

  String apiKey = "AIzaSyDttW16iZe-bhdBIQZFHYii3mdkH1-BsWs";

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
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
                child:TextField(controller: _phoneNumberController, maxLength: 8, keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "Phone number",
                      border: InputBorder.none,
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
                          Text("Choose location", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                          Padding(
                            padding: EdgeInsets.only(top:10, bottom:10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  /* check or loading round */
                                  /*  StreamBuilder<DeliveryAddressModel>(
                                      stream: userDataBloc.locationDetails,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          DeliveryAddressModel tmp = snapshot.data;
                                          if (tmp != null) {
                                            address.quartier = tmp.quartier;
                                            address.description = tmp.description;
                                            _checkLocationLoading = false;
                                          }
                                          return Container();
                                        } else if (snapshot.hasError) {
                                          return Container();
                                        }
                                        return _checkLocationLoading ? SizedBox(height: 15, width: 15,child: Center(child: CircularProgressIndicator(strokeWidth: 2))) : Container();
                                      }
                                  ),*/
                                  _checkLocationLoading ? SizedBox(height: 15, width: 15,child: Center(child: CircularProgressIndicator(strokeWidth: 2))) : Container(),
                                  !_checkLocationLoading && address?.location != null ? Icon(Icons.check_circle, color: KColors.primaryColor) : Container(),
                                  SizedBox(width: 10),
                                  Icon(Icons.chevron_right, color: KColors.primaryColor)
                                ]),
                          )],
                      )),onTap: () => showPlacePicker(context),
                ),
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
                  RaisedButton(padding: EdgeInsets.only(top:10, bottom: 10, left:5, right:5), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Row(
                    children: <Widget>[
                      Text("CONFIRM", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                  MaterialButton(padding: EdgeInsets.only(top:10, bottom: 10), shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)), child: Text("CANCEL", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),color: Colors.white, onPressed: () => _exit())
                ],
              )
            ]
        ),
      ),
    );
  }

  void showPlacePicker (BuildContext context) async {

    /* get last know position */
    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();

    if(geolocationStatus == GeolocationStatus.granted) {
      _jumpToPickAddressPage();
    } else {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);
      geolocationStatus = await Geolocator().checkGeolocationPermissionStatus();
      if(geolocationStatus != GeolocationStatus.granted) {
        _jumpToPickAddressPage();
      }
    }
  }

  void _jumpToPickAddressPage() async {

    if (StateContainer.of(context).location != null)
      Pp.PlacePickerState.initialTarget = LatLng(StateContainer.of(context).location.latitude, StateContainer.of(context).location.longitude);

    /* get my position */
    //    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            Pp.PlacePicker(AppConfig.GOOGLE_MAP_API_KEY)));
    /* use this location to generate details about the place the user lives and so on. */
    if (result != null) {
      /*  */
      setState(() {
        _checkLocationLoading = true;
        address.location = "${result.latitude}:${result.longitude}";
      });
      print(address.location);
      // use mvp to launch a request and place the result here.
//      userDataBloc.checkLocationDetails(userToken: UserTokenModel.fake(), position: Position(longitude: result.longitude, latitude: result.latitude));
      widget.presenter.checkLocationDetails(widget.customer, position:  Position(longitude: result.longitude, latitude: result.latitude));
    } else {}
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
      message: "Address modification failure",
      isYesOrNo: false,
    );
  }

  @override
  void createdSuccess() {
    /* created successful */
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.address_creation_success,
      message: "Address creation success",
      isYesOrNo: false,
    );
  }

  @override
  void createFailure() {
    /* created failure */
    _showDialog(
      icon: VectorsData.address_creation_error,
      message: "Address creation failure",
      isYesOrNo: false,
    );
  }

  @override
  void modifiedSuccess() {
    /* modified successful */
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.address_creation_success,
      message: "Address modification success",
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
                child: new Text("REFUSE", style: TextStyle(color:Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text("ACCEPT", style: TextStyle(color:KColors.primaryColor)),
                onPressed: (){
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text("OK", style: TextStyle(color:KColors.primaryColor)),
                onPressed: () {
                  if (okBackToHome){
                    Navigator.of(context).pop({'ok':true});
                    Navigator.of(context).pop({'ok':true});
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

    _checkLocationActivated();
    // save in to state container.
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    if (position != null)
      StateContainer.of(context).updateLocation(location: position);
  }

  _checkLocationActivated () async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Can't get gurrent location"),
              content:
              const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
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
  }

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
    mToast("Please, pick gps location again.");
  }

  void mToast(String message) {
Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void networkError() {
    mToast("Network error, please try again.");
  }


}
