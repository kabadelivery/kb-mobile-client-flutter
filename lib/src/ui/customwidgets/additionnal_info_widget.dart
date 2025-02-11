import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../localizations/AppLocalizations.dart';

Widget AdditionnalInfo(BuildContext context){
  TextEditingController _infoController = TextEditingController();
  return Container(
    decoration: BoxDecoration(
      color: Color(0x42d2d2d2),
      ),
    child:  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _infoController,
        maxLines: 4, // Allows multiple lines like a comment section
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontSize: 12
          ),
          hintText: "${AppLocalizations.of(context).translate('additional_info')}...",
          border: InputBorder.none,
        ),
      ),
    ),
  );
}