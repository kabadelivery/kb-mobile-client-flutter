import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/plus_code/open_location_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentLocationTile extends StatefulWidget {
  CustomerModel customer;

  CurrentLocationTile({Key key}) : super(key: key);

  @override
  _CurrentLocationTileState createState() {
    return _CurrentLocationTileState();
  }
}

class _CurrentLocationTileState extends State<CurrentLocationTile> {
  @override
  void initState() {
    super.initState();

    CustomerUtils.getCustomer().then((customer) {
      if (customer != null && customer?.id != null) {
        widget.customer = customer;
        CustomerUtils.getSavedAddressLocally().then((value) {
          setState(() {
            StateContainer.of(context).selectedAddress = value;
            String latitude = StateContainer.of(context)
                .selectedAddress
                .location
                .split(":")[0];
            String longitude = StateContainer.of(context)
                .selectedAddress
                .location
                .split(":")[1];
            StateContainer.of(context).location = Position(
                latitude: double.parse(latitude),
                longitude: double.parse(longitude));
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    //   load delivery address model if exists and if user is logged
  }

  _locationToPlusCode(Position location) {
    return encode(location.latitude, location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: StateContainer?.of(context)?.location == null ||
                StateContainer.of(context).selectedAddress == null
            ? Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: KColors.mBlue.withAlpha(10),
                    borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            child: Icon(Icons.location_on,
                                color: KColors.mBlue, size: 15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: KColors.mBlue.withAlpha(30)),
                            padding: EdgeInsets.all(5)),
                        SizedBox(width: 10),
                        Text(
                            Utils.capitalize(
                                "${AppLocalizations.of(context).translate('please_select_main_location')}"),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                      ],
                    ),
                    Container(
                        child: Icon(Icons.add,
                            color: KColors.primaryColor, size: 15),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: KColors.primaryColor.withAlpha(30)),
                        padding: EdgeInsets.all(5)),
                  ],
                ),
              )
            : Container(
                margin:
                    EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: KColors.mBlue.withAlpha(10),
                    borderRadius: BorderRadius.circular(5)),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            child: Icon(Icons.location_on,
                                color: KColors.mBlue, size: 15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: KColors.mBlue.withAlpha(30)),
                            padding: EdgeInsets.all(5)),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: Text(
                                  Utils.capitalize(
                                      "${StateContainer.of(context).selectedAddress?.name}"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: KColors.new_black)),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: RichText(
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: Utils.capitalize(
                                      "${AppLocalizations.of(context).translate('near_by')} - "),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  children: [
                                    TextSpan(
                                        text: Utils.capitalize(
                                            "${StateContainer.of(context).selectedAddress?.near}"),
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Text(
                                "${_locationToPlusCode(StateContainer.of(context).location)}",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                        child: Icon(FontAwesome.chevron_down,
                            color: KColors.primaryColor, size: 10),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: KColors.primaryColor.withAlpha(30)),
                        padding: EdgeInsets.all(5)),
                  ],
                ),
              ),
      ),
      onTap: () => {_pickMyAddress()},
    );
  }

  _pickMyAddress() async {
    /* confirm that customer has authorized location permission before moving forward */
    if (StateContainer.of(context).loggingState == 0) {
      // not logged in... show dialog and also go there
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "${AppLocalizations.of(context).translate('please_login_before_going_forward_title')}"),
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
                            image:
                                new AssetImage(ImageAssets.login_description),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate("please_login_before_going_forward_description_account")}",
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    "${AppLocalizations.of(context).translate('not_now')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('login')}"),
                onPressed: () {
                  /* */
                  /* jump to login page... */
                  Navigator.of(context).pop();

                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginPage(presenter: LoginPresenter())));
                },
              )
            ],
          );
        },
      );
      return;
    }

    _confirmHasAddress(() async {
      /* jump and get it */
      Map results = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MyAddressesPage(pick: true, presenter: AddressPresenter()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end);
            var curvedAnimation =
                CurvedAnimation(parent: animation, curve: curve);
            return SlideTransition(
                position: tween.animate(curvedAnimation), child: child);
          }));

      if (results != null && results.containsKey('selection')) {
        setState(() {
          StateContainer.of(context).selectedAddress = results['selection'];
          StateContainer.of(context).selectedAddress =
              StateContainer.of(context).selectedAddress;
          /* must save this location locally */
          String latitude =
              StateContainer.of(context).selectedAddress.location.split(":")[0];
          String longitude =
              StateContainer.of(context).selectedAddress.location.split(":")[1];
          StateContainer.of(context).location = Position(
              latitude: double.parse(latitude),
              longitude: double.parse(longitude));
        });
        CustomerUtils.saveAddressLocally(
            StateContainer.of(context).selectedAddress);
      }
    });
  }

  Future<void> _confirmHasAddress(Function continuePickingAddress) async {
    var prefs = await SharedPreferences.getInstance();

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
                "${AppLocalizations.of(context).translate('request')}"
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
                            image: new AssetImage(ImageAssets.address),
                          ))),
                  SizedBox(height: 10),
                  Text(
                    "${AppLocalizations.of(context).translate('location_explanation_pricing')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('refuse')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('accept')}"),
                onPressed: () {
                  /* */
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("_has_accepted_gps", "ok");
                  // call get location again...
                  _confirmHasAddress(continuePickingAddress);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else {
      // permission has been accepted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        /*  ---- */
        // await Geolocator.openAppSettings();
        /* ---- */
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('permission_')}"
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
                              image: new AssetImage(ImageAssets.address),
                            ))),
                    SizedBox(height: 10),
                    Text(
                      "${AppLocalizations.of(context).translate('request_location_permission')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    )
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
                  onPressed: () async {
                    /* */
                    await Geolocator.openAppSettings();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        /* ---- */
      } else if (permission == LocationPermission.denied) {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('permission_')}"
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
                              image: new AssetImage(ImageAssets.address),
                            ))),
                    SizedBox(height: 10),
                    Text(
                      "${AppLocalizations.of(context).translate('request_location_permission')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    )
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
                  onPressed: () async {
                    /* */
                    Geolocator.requestPermission();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        /* ---- */
      } else {
        // location is enabled
        bool isLocationServiceEnabled =
            await Geolocator.isLocationServiceEnabled();
        if (!isLocationServiceEnabled) {
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context).translate('permission_')}"
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
                        "${AppLocalizations.of(context).translate('request_location_activation_permission')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      )
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
                    onPressed: () async {
                      /* */
                      await Geolocator.openLocationSettings();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
          /* ---- */
        } else {
          //  authorize
          continuePickingAddress();
        }
      }
    }
  }
}
