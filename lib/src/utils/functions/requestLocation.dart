import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localizations/AppLocalizations.dart';
import '../_static_data/ImageAssets.dart';

Future<void> requestLocation(BuildContext context) async {
  print("IN THE REQUEST");
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("${AppLocalizations.of(context)!.translate('info')}"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(ImageAssets.address),
                      ))),
              SizedBox(height: 10),
              Text(
                  "${AppLocalizations.of(context)!.translate('request_location_permission')}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14))
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("${AppLocalizations.of(context)!.translate('refuse')}"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("${AppLocalizations.of(context)!.translate('accept')}"),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("_has_accepted_gps", "ok");
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
