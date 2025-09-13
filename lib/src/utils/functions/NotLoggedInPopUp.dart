import 'package:KABA/src/ui/customwidgets/modals/Modal_2_connect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../StateContainer.dart';
import '../../contracts/login_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../../ui/screens/auth/login/LoginPage.dart';
import '../../utils/_static_data/ImageAssets.dart';
void NotLoggedInPopUp(BuildContext context){
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
    
      return const Modal_2_connect(); 
     
    },
  );
}