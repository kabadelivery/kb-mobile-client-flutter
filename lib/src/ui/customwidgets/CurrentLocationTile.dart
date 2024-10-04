import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/plus_code/open_location_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentLocationTile extends StatefulWidget {
  CurrentLocationTile({Key key}) : super(key: key);

  @override
  _CurrentLocationTileState createState() {
    return _CurrentLocationTileState();
  }
}

class _CurrentLocationTileState extends State<CurrentLocationTile> {
  SharedPreferences prefs;

  bool isPickLocation;

  @override
  void initState() {
    super.initState();
  }

  Stream<Placemark> _geo_location;

  @override
  void dispose() {
    super.dispose();
    //   load delivery address model if exists and if user is logged
  }

  @override
  Widget build(BuildContext context) {
    if (_geo_location == null && StateContainer.of(context).location != null) {
      _geo_location = (() {
        StreamController<Placemark> controller;
        controller = StreamController<Placemark>(
          onListen: () async {
            List<Placemark> placemarks;
            if (StateContainer.of(context).placemark == null) {
              if (StateContainer.of(context).is_offline) {
                // open_location_code
                Placemark mPlaceMark = Placemark(
                    name: encode(StateContainer.of(context).location.latitude,
                        StateContainer.of(context).location.longitude),
                    country: "WORLD",
                    locality: "Africa");
                controller.add(mPlaceMark);
                StateContainer.of(context).placemark = mPlaceMark;
              } else {
                placemarks = await placemarkFromCoordinates(
                    StateContainer.of(context).location.latitude,
                    StateContainer.of(context).location.longitude);
                // add local identifier
                if (placemarks?.length > 0) {
                  int s = 0;
                  try {
                    placemarks.forEach((element) {
                      if (element?.name?.contains("+"))
                        throw "";
                      else
                        s++;
                    });
                  } catch (e) {}
                  if (s >= placemarks.length - 1) s = 0;
                  await Future.delayed(Duration(seconds: 2));
                  controller.add(placemarks[s]);
                  StateContainer.of(context).placemark = placemarks[s];
                } else {
                  controller.addError({"message": "error"});
                }
              }
            } else {
              controller.add(StateContainer.of(context).placemark);
            }
            await controller.close();
          },
        );
        return controller.stream;
      })();
    }
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
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
                  child:
                      Icon(Icons.location_on, color: KColors.mBlue, size: 15),
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
                            "${AppLocalizations.of(context).translate("your_location")}"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: KColors.new_black)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  StateContainer.of(context).placemark == null
                      ? Container(
                          width: MediaQuery.of(context).size.width * .6,
                          child: StreamBuilder<Placemark>(
                            stream: _geo_location,
                            builder: (BuildContext context,
                                AsyncSnapshot<Placemark> snapshot) {
                              List<Widget> children;
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                children = <Widget>[
                                  Text(
                                      "${snapshot.data.name + ", " + snapshot.data.locality + ", " + snapshot.data.country}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12))
                                ];
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                children = <Widget>[
                                  /* LoadingAnimationWidget.prograssiveDots(
                                    color: KColors.mBlue,
                                    size: 18,
                                  ),*/
                                  Row(
                                    children: [
                                      Text(
                                          "${encode(StateContainer.of(context).location.latitude, StateContainer.of(context).location.longitude)}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      LoadingAnimationWidget.prograssiveDots(
                                        color: KColors.mBlue,
                                        size: 18,
                                      )
                                    ],
                                  )
                                ];
                              } else {
                                children = <Widget>[
                                  Text(
                                      "${StateContainer.of(context).location?.latitude}:${StateContainer.of(context).location?.latitude}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12))
                                ];
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: children,
                              );
                            },
                          ),
                        )
                      : Container(
                          child: Column(
                            children: [
                              Text(
                                  "${StateContainer.of(context).placemark.name + ", " + StateContainer.of(context).placemark.locality + ", " + StateContainer.of(context).placemark.country}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12))
                            ],
                          ),
                        ),
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
    );
  }
}
