import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/customwidgets/MRaisedButton.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/recustomlib/place_picker_removed_nearbyplaces.dart'
    as Pp;
import 'package:KABA/src/xrint.dart';

// import 'package:android_intent/android_intent.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class EditAddressPage extends StatefulWidget {
  static var routeName = "/EditAddressPage";

  DeliveryAddressModel address;

  EditAddressPresenter presenter;

  CustomerModel customer;

  DeliveryAddressModel createdAddress = null;

  String gps_location = "";

  bool locationConfirmed = false;

  EditAddressPage({Key key, this.address, this.presenter, this.gps_location})
      : super(key: key) {
    if (this.address?.location != null)
      locationConfirmed = true;
    else
      locationConfirmed = false;
  }

  @override
  _EditAddressPageState createState() => _EditAddressPageState(address);
}

class _EditAddressPageState extends State<EditAddressPage>
    implements EditAddressView {
//  String apiKey = "AIzaSyDttW16iZe-bhdBIQZFHYii3mdkH1-BsWs";

  LatLng selectedLocation;
  DeliveryAddressModel address;

  var _locationNameController = TextEditingController(),
      _phoneNumberController = TextEditingController(),
      _nearController = TextEditingController(),
      _descriptionController = TextEditingController();

  bool _checkLocationLoading = false;
  bool _isUpdateOrCreateAddressLoading = false;

  _EditAddressPageState(this.address) {
    if (address != null && address.location != null) {
      String latitude = address.location.split(":")[0];
      String longitude = address.location.split(":")[1];
      selectedLocation =
          LatLng(double.parse(latitude), double.parse(longitude));
    }
    if (address == null) {
      address = DeliveryAddressModel();
    }
  }

  SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.editAddressView = this;
    // if we are coming here with a gps location from another app, let us know
    if (widget.gps_location != null && "".compareTo(widget.gps_location) != 0) {
      address.location = widget.gps_location;
      Timer.run(() {
        widget.presenter.checkLocationDetails(widget.customer,
            position: Position(
                longitude: double.parse(widget.gps_location.split(":")[1]),
                latitude: double.parse(widget.gps_location.split(":")[0])));
        xrint("editaddress -> ${address.toJson().toString()}");
      });
    }
    widget.address = address;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      _getLastKnowLocation();
    });
    _locationNameController.text = address?.name;
    _phoneNumberController.text = address?.phone_number;
    _nearController.text = address?.near;
    _descriptionController.text = address?.description;
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
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('edit_address')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          /* boxes to show the pictures selected. */
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: TextField(
                controller: _locationNameController,
                minLines: 2,
                maxLines: 5,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context).translate('location_name')}",
                  hintMaxLines: 5,
                  border: InputBorder.none,
                )),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: TextField(
                controller: _phoneNumberController,
                maxLength: 8,
                keyboardType: TextInputType.phone,
                minLines: 2,
                maxLines: 5,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context).translate('phone_number')}",
                  border: InputBorder.none,
                  hintMaxLines: 5,
                )),
          ),
          SizedBox(height: 10),
          Container(
            color: Colors.white.withAlpha(200),
            child: InkWell(
              splashColor: Colors.red,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      !_checkLocationLoading && address?.location != null
                          ? Text(
                              "${AppLocalizations.of(context).translate('choose_location')}",
                              style: TextStyle(
                                  color: KColors.primaryColor, fontSize: 15))
                          : BouncingWidget(
                              duration: Duration(milliseconds: 400),
                              scaleFactor: 2,
                              onPressed: () => showPlacePicker(context),
                              child: Text(
                                  "${AppLocalizations.of(context).translate('choose_location')}",
                                  style: TextStyle(
                                      color: KColors.primaryColor,
                                      fontSize: 15)),
                            ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
//                                  isPickLocation
                              isPickLocation
                                  ? SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.green))))
                                  : Container(),
                              _checkLocationLoading
                                  ? SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)))
                                  : Container(),
                              SizedBox(width: 5),
                              !_checkLocationLoading &&
                                      address?.location != null &&
                                      widget.locationConfirmed
                                  ? Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: KColors.primaryColor
                                              .withAlpha(30),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context).translate('gps_')} ",
                                              style: TextStyle(
                                                  color: KColors.primaryColor)),
                                          Icon(Icons.check_circle,
                                              color: KColors.primaryColor),
                                          Text("K",
                                              style: TextStyle(
                                                  color: KColors.primaryColor)),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              SizedBox(width: 5),
                              !_checkLocationLoading &&
                                      address?.location != null
                                  ? Icon(Icons.chevron_right,
                                      color: KColors.primaryColor)
                                  : BouncingWidget(
                                      duration: Duration(milliseconds: 300),
                                      scaleFactor: 2,
                                      onPressed: () => showPlacePicker(context),
                                      child: Icon(Icons.chevron_right,
                                          color: KColors.primaryColor),
                                    ),
                            ]),
                      )
                    ],
                  )),
              onTap: () => showPlacePicker(context),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: TextField(
                controller: _nearController,
                minLines: 2,
                maxLines: 5,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context).translate('not_far_from')}",
                  border: InputBorder.none,
                )),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 5,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText:
                      "${AppLocalizations.of(context).translate('address_details')}",
                  border: InputBorder.none,
                )),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MRaisedButton(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
            /*      shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),*/
                  child: Row(
                    children: <Widget>[
                      Text(
                          "${AppLocalizations.of(context).translate('confirm')}",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      _isUpdateOrCreateAddressLoading
                          ? Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                SizedBox(
                                    child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white)),
                                    height: 15,
                                    width: 15),
                                SizedBox(width: 5),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  color: KColors.primaryColor,
                  onPressed: () => _saveAddress()),
              SizedBox(width: 10),
              MaterialButton(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  child: Text(
                      "${AppLocalizations.of(context).translate('cancel')}",
                      style:
                          TextStyle(fontSize: 16, color: KColors.primaryColor)),
                  color: Colors.white,
                  onPressed: () => _exit())
            ],
          )
        ]),
      ),
    );
  }

  StreamSubscription<Position> positionStream;

  void showPlacePicker(BuildContext context) async {
    // confirm you want localisation here...
    if (StateContainer.of(context).location != null)
      _jumpToPickAddressPage();
    else
      SharedPreferences.getInstance().then((value) async {
        prefs = value;
        String _has_accepted_gps = prefs.getString("_has_accepted_gps");
        /* no need to commit */
        /* expiration date in 3months */
        if (_has_accepted_gps != "ok") {
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text("${AppLocalizations.of(context).translate('info')}"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new AssetImage(
                                    ImageAssets.location_permission),
                              ))),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context).translate('location_explanation')}",
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('accept')}"),
                    onPressed: () {
                      /* */
                      // SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("_has_accepted_gps", "ok");
                      // call get location again...
                      showPlacePicker(context);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        } else {
          /* get last know position */
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.deniedForever) {
            await Geolocator.openAppSettings();
          } else if (permission == LocationPermission.denied) {
            Geolocator.requestPermission();
          } else {
            // location is enabled
            bool isLocationServiceEnabled =
                await Geolocator.isLocationServiceEnabled();
            if (!isLocationServiceEnabled) {
              /* dialog to activate gps location */
              await Geolocator.openLocationSettings();
            } else {
              if (isPickLocation) {
                xrint("already picking address, OUTTTTT");
                return;
              } else {
                setState(() {
                  isPickLocation = true;
                });
                await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                // _jumpToPickAddressPage();

        Stream<Position> positionStream =
                    Geolocator.getPositionStream();
                positionStream.first.then((position) {
                  xrint("position stream");
                  /* do it recursevely until two positions are identical*/
                  positionStream = Geolocator.getPositionStream();
                  positionStream.first.then((position1) {
                    // we do it twice to make sure we get a good location
                    _jumpToPickAddressPage();
                  }).catchError((onError) {
                    setState(() {
                      isPickLocation = false;
                    });
                  });
                }).catchError((onError) {
                  setState(() {
                    isPickLocation = false;
                  });
                });
              }
            }
          }
        }
      });
  }

  bool isPickLocation = false;

  void _jumpToPickAddressPage() async {
    lo.LocationData location = await lo.Location().getLocation();

    StateContainer.of(context).updateLocation(
        location: Position(
            latitude: location.latitude, longitude: location.longitude));

    /*if (StateContainer.of(context)?.location != null)
      Pp.PlacePickerState.initialTarget = LatLng(StateContainer
          .of(context)
          .location
          .latitude, StateContainer
          .of(context)
          .location
          .longitude);*/

    xrint(widget.gps_location);
    if (widget.locationConfirmed && widget.address?.location != null) {
      xrint("moving to pre-registered location");
      Pp.PlacePickerState.initialTarget = LatLng(
        double.parse(widget.address?.location?.split(":")[0]),
        double.parse(widget.address?.location?.split(":")[1]),
      );
    } else {
      xrint("moving to me");
      Pp.PlacePickerState.initialTarget = LatLng(
          StateContainer.of(context).location.latitude,
          StateContainer.of(context).location.longitude);
    }
    xrint("i pick address");

    /* get my position */
    LatLng result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Pp.PlacePicker(AppConfig.GOOGLE_MAP_API_KEY,
            alreadyHasLocation: widget.locationConfirmed)));
    /* use this location to generate details about the place the user lives and so on. */
    widget.locationConfirmed = false;
    widget.presenter.editAddressView = this;

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      if (result != null) {
        setState(() {
          _checkLocationLoading = true;
          address.location = "${result.latitude}:${result.longitude}";
        });
        xrint(address.location);
        // use mvp to launch a request and place the result here.
        widget.presenter.checkLocationDetails(widget.customer,
            position: Position(
                longitude: result.longitude, latitude: result.latitude));
      }
      setState(() {
        isPickLocation = false;
      });
    });
  }

  void _exit() {
    Navigator.of(context).pop();
  }

  _saveAddress() {
    address.name = _locationNameController.text;
    address.description = _descriptionController.text;
    address.near = _nearController.text;
    address.phone_number = _phoneNumberController.text;

    /* exces d'intelligence */
    widget.presenter.editAddressView = this;

    /*  */ /* validations ? */ /*
    if ("".compareTo(_locationNameController.text) == 0 || _locationNameController.text?.length < 3) {
      showErrorMessageDialog("Please enter a specific address name");
      return;
    }

    if ("".compareTo(_phoneNumberController.text) == 0
        || _phoneNumberController.text?.length < 3) {
      showErrorMessageDialog("Please enter a specific phone number to contact");
      return;
    }

    if ("".compareTo(address?.location) == 0 || address?.location == null) {
      showErrorMessageDialog("Please choose your GPS location");
      return;
    }

    if ("".compareTo(_nearController.text) == 0 || _nearController.text?.length != null
        || _nearController.text?.length < 3) {
      showErrorMessageDialog("Please enter a specific mention for near by");
      return;
    }

    if ("".compareTo(_descriptionController.text) == 0 || _descriptionController.text?.length != null
        || _descriptionController.text?.length < 3) {
      showErrorMessageDialog("Please enter a specific address description");
      return;
    }

*/
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.updateOrCreateAddress(address, widget.customer);
    });
  }

  @override
  void addressModificationFailure(String message) {
    /* error. */
    _showDialog(
//      okBackToHome: true,
      icon: VectorsData.address_creation_error,
      message:
          "${AppLocalizations.of(context).translate('address_modification_failure')}",
      isYesOrNo: false,
    );
  }

  void showErrorMessageDialog(String message) {
    _showDialog(
      icon: VectorsData.address_creation_error,
      message: "${message}",
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
      message:
          "${AppLocalizations.of(context).translate('address_creation_success')}",
      isYesOrNo: false,
    );
  }

  @override
  void createFailure() {
    /* created failure */
    _showDialog(
      icon: VectorsData.address_creation_error,
      message:
          "${AppLocalizations.of(context).translate('address_modification_failure')}",
      isYesOrNo: false,
    );
  }

  @override
  void modifiedSuccess() {
    /* modified successful */
    _showDialog(
      okBackToHome: true,
      icon: VectorsData.address_creation_success,
      message:
          "${AppLocalizations.of(context).translate('address_modification_success')}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {var icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes,
      bool isSvg = true}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              /* icon */
              SizedBox(
                  height: 80,
                  width: 80,
                  child: isSvg
                      ? SvgPicture.asset(
                          icon,
                        )
                      : Image.asset(icon)),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    // usually buttons at the bottom of the dialog
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    //
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        if (okBackToHome) {
                          Navigator.of(context).pop({
                            'ok': true,
                            'createdAddress': widget.createdAddress
                          });
                          Navigator.of(context).pop({
                            'ok': true,
                            'createdAddress': widget.createdAddress
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ]);
      },
    );
  }

  @override
  void showLoading(bool isLoading) {}

  @override
  void inflateDescription(String description_details, String suburb) {
    showAddressDetailsLoading(false);
    setState(() {
      widget.locationConfirmed = true;
      address.description = description_details;
      _descriptionController.text = description_details;
      address.quartier = suburb;

      /* if gps_location != null . then show a box to confirm the picking of the address */
      mDialog(
          "${AppLocalizations.of(context).translate('gps_location_valid')}");
    });
  }

  @override
  void inflateDetails(String addressDetails) {}

  Future _getLastKnowLocation() async {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      String _has_accepted_gps = prefs.getString("_has_accepted_gps");
      /* no need to commit */
      /* expiration date in 3months */

      if (_has_accepted_gps != "ok") {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('info')}"
                      .toUpperCase(),
                  style: TextStyle(color: KColors.primaryColor)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    /* add an image*/
                    // location_permission
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: new AssetImage(
                                  ImageAssets.location_permission),
                            ))),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context).translate('location_explanation')}",
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('refuse')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('accept')}"),
                  onPressed: () {
                    /* */
                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("_has_accepted_gps", "ok");
                    // call get location again...
                    _getLastKnowLocation();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        } else if (permission == LocationPermission.denied) {
          Geolocator.requestPermission();
        } else {
          // location is enabled
          bool isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          if (!isLocationServiceEnabled) {
            await Geolocator.openLocationSettings();
          } else {
            positionStream =
                Geolocator.getPositionStream().listen((Position position) {
              if (position != null && mounted)
                StateContainer.of(context).updateLocation(location: position);
            });
          }
        }
      }
    });
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
    mToast("${AppLocalizations.of(context).translate('gps_pick_again')}");
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void networkError() {
    mToast("${AppLocalizations.of(context).translate('network_error')}");
  }

  void mDialog(String message) {
    _showDialog(
        okBackToHome: false,
        icon: ImageAssets.address_location_pick_ok,
        message: message,
        isYesOrNo: false,
        isSvg: false);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
