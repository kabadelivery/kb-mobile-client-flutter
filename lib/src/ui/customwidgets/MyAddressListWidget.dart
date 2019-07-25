import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class MyAddressListWidget extends StatefulWidget {

  MyAddressListWidget();

  @override
  _MyAddressListWidgetState createState() {
    // TODO: implement createState
    return _MyAddressListWidgetState();
  }

}

class _MyAddressListWidgetState extends State<MyAddressListWidget> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          Card(child:ListTile(
            title: Padding(padding: EdgeInsets.only(top: 10), child: Text("MAISON YANNICK", style: TextStyle(color: Colors.black.withAlpha(180), fontWeight: FontWeight.bold,fontSize: 18))),
            subtitle: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Text("Prochain carrefour apreès carrefour assigomé en allant vers Zossimé. Tourner ensuite aà gauche et prendre devant ooh!",maxLines: 2,
                style: TextStyle(fontSize: 14, color: Colors.grey))),
                Row(children: <Widget>[Text("Contact", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color:Colors.black)), SizedBox(width: 10),
                  Text("90628725", style: TextStyle(fontSize: 16, color: Colors.lightBlue, fontWeight: FontWeight.bold))])
              ],
            ),
            trailing: IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: _editAddressAt(0)),
          ))
      );
  }

  _editAddressAt(int position) {


  }



}