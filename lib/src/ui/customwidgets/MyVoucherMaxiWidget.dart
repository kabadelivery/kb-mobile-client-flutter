import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/VoucherDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';


class MyVoucherMaxiWidget extends StatefulWidget {

  MyVoucherMaxiWidget();

  @override
  _MyVoucherMaxiWidgetState createState() {
    return _MyVoucherMaxiWidgetState();
  }

}

class _MyVoucherMaxiWidgetState extends State<MyVoucherMaxiWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        child: (
            Column(
              children: <Widget>[
                Column(children: <Widget>[
                  SizedBox(height: 10),
                  Text("Wings'n Shake TOTSI", textAlign: TextAlign.left, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("-1000 de réduction sur toutes vos commandes au Wing's shake Totsi.", textAlign: TextAlign.left),
                  SizedBox(height: 10),
                  Text("(Promotion Valable uniquement dans ce restaurant)", textAlign: TextAlign.left),
                  SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("TOTSIPOULET2007"),
                        Text("5000")
                      ]
                  ),
                  SizedBox(height: 10),
                  Text("Expire le 20/07", textAlign: TextAlign.center),
                  SizedBox(height: 10),
                ]),
                /* space for the code promo it's self */
                ClipPath(
                  clipper: VoucherMaxMiddleClipper(),
                  child: Container(width: MediaQuery.of(context).size.width, height:60,
                    child: Text("WNSTOTSI0720"),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top:50, bottom: 10),
                    child: Text("Expires on 20/07"
                    )
                )
              ],
            )
        ),
      );
  }

  _jumpToVoucherDetails() {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailsPage(),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            VoucherDetailsPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
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
                Text("-55%",style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: KColors.new_black.withAlpha(150))),
              ]),
              /* bottom level */
              Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,  children: <Widget>[
              Row(children: <Widget>[/* icon */IconButton(icon: Icon(Icons.watch_later, color: KColors.new_black), onPressed: () {},), /*text */Text("2019/04/05")]),
                IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {},)
              ]),
            ]
          )))
      );
  }
 */

}

class VoucherMaxMiddleClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    path.arcToPoint(Offset(0,60));
    path.lineTo(size.width, size.height);
    path.arcToPoint(Offset(size.width,0));
    path.lineTo(0,0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip (VoucherMaxMiddleClipper oldClipper) => true;
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