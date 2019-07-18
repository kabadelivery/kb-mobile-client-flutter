import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';


class EditAddressPage extends StatefulWidget {

  static var routeName = "/EditAddressPage";

  EditAddressPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                child:TextField(
                    decoration: InputDecoration(labelText: "Name of Location",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Phone number",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Select Position", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.check_circle, color: KColors.primaryColor), onPressed: () {}),
                            SizedBox(width: 10),
                            IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: () {})
                          ])],
                  )),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Not so far from",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child:TextField(
                    decoration: InputDecoration(labelText: "Address Details",
                      border: InputBorder.none,
                    )),
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(child: Text("CONFIRM", style: TextStyle(fontSize: 16, color: Colors.white)),color: KColors.primaryColor, onPressed: () {}),
                  SizedBox(width: 10),
                  MaterialButton(child: Text("CANCEL", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),color: Colors.white, onPressed: () {})
                ],
              )
            ]
        ),
      ),
    );
  }
}
