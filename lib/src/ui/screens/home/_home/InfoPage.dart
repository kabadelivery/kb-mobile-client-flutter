import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaba_flutter/src/utils/_static_data/ImageAssets.dart';
import 'package:package_info/package_info.dart';



class InfoPage extends StatefulWidget {

  static var routeName = "/InfoPage";

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  String version = "~";

  @override
  void initState() {

    super.initState();
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
              Positioned(left: 10, top:10, child: IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.close, color: Colors.black))),
              Column(
                children: <Widget>[
                  Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[Text("Version: ${version}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))]), flex: 1, ),
                  Expanded(child: Image(image: AssetImage(ImageAssets.kaba_copyright_presentation), width: MediaQuery.of(context).size.width), flex: 5),
                ],
              ),
            ],
          ),
        )
    );
  }
}
