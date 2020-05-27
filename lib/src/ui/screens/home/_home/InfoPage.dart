import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:package_info/package_info.dart';



class InfoPage extends StatefulWidget {

  static var routeName = "/InfoPage";

  String year = "";

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  String version = "~";

  @override
  void initState() {

    super.initState();

    DateTime date = DateTime.now();
   setState(() {
     widget.year = "${date.year}";
   });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        this.version = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Stack(
            children: <Widget>[
             Positioned(left: 10, top:35, child: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(FontAwesomeIcons.timesCircle, size: 40, color: Colors.black))),
              Column(
                children: <Widget>[
                  Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[Text("${AppLocalizations.of(context).translate('version')} ${version}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))]), flex: 1, ),
                  Expanded(child: Image(image: AssetImage(ImageAssets.kaba_copyright_presentation), width: MediaQuery.of(context).size.width), flex: 5),
                ],
              ),
              Positioned(bottom: 20, right:0, left:0,child: Text("${AppLocalizations.of(context).translate('info_page_informations')} ${widget.year}", style: TextStyle(fontSize: 15, color: KColors.primaryColor), textAlign: TextAlign.center)),
            ],
          ),
        )
    );
  }
}
