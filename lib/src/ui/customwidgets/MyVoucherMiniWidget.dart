import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class MyVoucherMiniWidget extends StatefulWidget {

  MyVoucherMiniWidget();

  @override
  _MyVoucherMiniWidgetState createState() {
    return _MyVoucherMiniWidgetState();
  }

}

class _MyVoucherMiniWidgetState extends State<MyVoucherMiniWidget> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
          Card(
//              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                    colors: [const Color(0xFFEAEB12), const Color(0xFFF1AA00)], // whitish to gray
                    tileMode: TileMode.repeated, // repeats the gradient over the canvas
                  ),
                ),
                child: InkWell(
                  onTap: () => _jumpToVoucherDetails(),
                  child: SizedBox(
                    child: Stack(
                      children: <Widget>[
                        Positioned(bottom:10,right:10,child: Icon(Icons.directions_bike)),
                        Container(
                            margin: EdgeInsets.only(left:20, right:20),
                            child: Column(children: <Widget>[
                              SizedBox(height: 10),
                              Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("Wings'n Shake TOTSI".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("TOTSIPOULET2007", style: TextStyle(fontSize: 18)),
                                    Text("-10%", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: KColors.primaryColor))
                                  ]
                              ),
                              SizedBox(height: 10),
                              Text("Expire le 20/07", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                              SizedBox(height: 10),
                            ])
                        ),
                      ],
                    ),
                  )),
              ));

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