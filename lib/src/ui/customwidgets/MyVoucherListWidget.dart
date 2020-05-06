import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class MyVoucherListWidget extends StatefulWidget {

  MyVoucherListWidget();

  @override
  _MyVoucherListWidgetState createState() {
    // TODO: implement createState
    return _MyVoucherListWidgetState();
  }

}

class _MyVoucherListWidgetState extends State<MyVoucherListWidget> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      ClipPath(
        clipper: VoucherListItemClipper(),
        child: (
            Card(margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                child: SizedBox(
                  height: 120,
                  child:  InkWell(onTap: () => _jumpToVoucherDetails(),
                    child: Container(
                      child: Row(children: <Widget>[
                        Expanded(child: Container(constraints: BoxConstraints.expand(),child: Center(child:
                        Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                          Text('2000',  style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
                          Text(" FCFA", style: TextStyle(fontSize: 8, color: Colors.white)),
                        ])), color: KColors.primaryColor), flex: 3),
                        Expanded(child: Container(padding: EdgeInsets.all(10), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                          Text("WINGS'N SHAKE TOTSI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,  children: <Widget>[
                            Column(
                              children: <Widget>[
                                /* if not yet, */
                                Container(padding: EdgeInsets.only(left:2, right: 2), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                                    border: new Border.all(color: Colors.transparent),
                                    color: Colors.green.withAlpha(100)
                                ), child: Row(children: <Widget>[Icon(Icons.blur_on, color: Colors.black, size: 20),
                                  Text("2019/04/05", style: TextStyle(color: Colors.black,fontSize: 10))])),
                                SizedBox(height: 5),
                                /* if already, expiry date */
                                Container(padding: EdgeInsets.only(left:2, right: 2), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                                    border: new Border.all(color: Colors.transparent),
                                    color: Colors.red.withAlpha(100)
                                ), child: Row(children: <Widget>[Icon(Icons.blur_off, color: Colors.black, size: 20),
                                  Text("2019/04/05", style: TextStyle(color: Colors.black,fontSize: 10))])),
                              ],
                            ),
                            Icon(FontAwesomeIcons.qrcode, color: Colors.black, size: 20)
                          ]),
                        ])),flex: 5)
                      ]),
                    ),
                  ),
                ))
        ),
      );
  }

  _jumpToVoucherDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailsPage(),
      ),
    );
  }


/*  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          Card(margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            color: Colors.orange.withAlpha(120),
              child:Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
              child:Column(
            children: <Widget>[
              /* top level */
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children: <Widget>[
                Text("WINGS'S SHAKE BAGUIDA"),
                Row(children: <Widget>[/* icon */IconButton(icon: Icon(Icons.person, color: Colors.white), onPressed: () {},), /*text */Text("2/4")])
              ]),
              /* middle level*/
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children: <Widget>[
                Text("PAQUES2019", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("-55%",style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black.withAlpha(150))),
              ]),
              /* bottom level */
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,  children: <Widget>[
              Row(children: <Widget>[/* icon */IconButton(icon: Icon(Icons.watch_later, color: Colors.black), onPressed: () {},), /*text */Text("2019/04/05")]),
                IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {},)
              ]),
            ]
          )))
      );
  }
 */

}

class VoucherListItemClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    double teethDeepth = 30;
    path.lineTo(teethDeepth, teethDeepth*0.60);
    path.lineTo(0, teethDeepth*0.60);
    path.lineTo(teethDeepth, teethDeepth);
    path.lineTo(0, teethDeepth);
    path.lineTo(teethDeepth, teethDeepth*1.5);
    path.lineTo(0, teethDeepth*1.5);
    path.lineTo(teethDeepth, teethDeepth*2);
    path.lineTo(0, teethDeepth*2);
    path.lineTo(teethDeepth, teethDeepth*2.5);
    path.lineTo(0, teethDeepth*2.5);
    path.lineTo(teethDeepth, teethDeepth*3);
    path.lineTo(0, teethDeepth*3);
    path.lineTo(teethDeepth, teethDeepth*3.5);
    path.lineTo(0, teethDeepth*3.5);
    path.lineTo(teethDeepth, teethDeepth*4);
    path.lineTo(0, teethDeepth*4);
    path.lineTo(teethDeepth, teethDeepth*4.5);
    path.lineTo(0, teethDeepth*4.5);

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip (VoucherListItemClipper oldClipper) => true;

}