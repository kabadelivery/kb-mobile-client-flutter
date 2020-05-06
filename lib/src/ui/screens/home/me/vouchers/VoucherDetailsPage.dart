import 'package:flutter/material.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherListWidget.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/QrCodeScanner.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';


class VoucherDetailsPage extends StatefulWidget {

  static var routeName = "/VoucherDetailsPage";

  VoucherDetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VoucherDetailsPageState createState() => _VoucherDetailsPageState();
}

class _VoucherDetailsPageState extends State<VoucherDetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: KColors.primaryColor,
        appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
            backgroundColor: Colors.white,
            title: Text("VOUCHER DETAILS", style:TextStyle(color:KColors.primaryColor))),
        body:  _buildVoucherDetailsPage(null)/*StreamBuilder<VoucherDetailsPage>(
          stream: null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildVoucherDetailsPage(snapshot.data);
            } else if (snapshot.hasError) {
              return ErrorPage(onClickAction: (){*//*userDataBloc.fetchDailyOrders(UserTokenModel.fake());*//*});
            }
            return Center(child: CircularProgressIndicator());
          }
      ),*/
    );
  }

  Widget _buildVoucherDetailsPage(VoucherDetailsPage data) {
    return SingleChildScrollView(
      child:   ClipPath(
        clipper: VoucherClipper(),
        child: Card(
          margin: EdgeInsets.only(left:40, right: 40, top: 30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
            child: Column(
                children: <Widget>[
                  /* code qr; s'il est possible de partager cela */
                  Container(height: 160, width: 160,
                      child: QrImage(
                        data: 'This is a simple QR code',
                        version: QrVersions.auto,
                        size: 160,
                        gapless: false,
                        foregroundColor: Colors.black,
                        embeddedImage: AssetImage('assets/images/png/kaba_log_red_man_square.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(35, 35),
                        ),
                      )
                  ),

                  SizedBox(height: 10),

                  /* price */
                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    Text('2000',  style: new TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 22)),
                    Text(" FCFA", style: TextStyle(fontSize: 10, color: KColors.primaryColor)),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    Text('50',  style: new TextStyle(fontWeight: FontWeight.bold, color: KColors.primaryColor, fontSize: 22)),
                    Text(" %", style: TextStyle(fontSize: 16, color: KColors.primaryColor)),
                  ]),

                  /* details du restaurant */
                  SizedBox(height: 20),
                  Text("WINGS'N SHAKE TOTSI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey.withAlpha(100)),
                  /* repas concernes */
                  SizedBox(height: 20),
                  Text('WINGS 5P / SALADE VERTE / WINGS 10PIECES',textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey.withAlpha(100)),
                  /* debut d'utilisation */
                  SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            children: <Widget>[
                              Text("Available Since", style: TextStyle(color: Colors.green)),
                              Text("2019-02-20")
                            ]
                        ),
                        Column(
                            children: <Widget>[
                              Text("Expiry date",  style: TextStyle(color: KColors.primaryColor)),
                              Text("2019-02-20")
                            ]
                        )
                      ]),
                  /* powered by */
                  SizedBox(height: 20),
                  Text('Powered By Kaba Technlogies', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ]
            ),
          ),
        ),
      ),
    );
  }

}

class VoucherClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
//    path.lineTo(0.0, size.height);
//    path.arcToPoint(Offset(size.width, size.height), radius: Radius.circular(1000));
//    path.lineTo(size.width, 0);
//    path.close();
    double radius = 120;

    /* path.moveTo(radius, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius));
//    path.lineTo(0, radius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, radius);

    path.lineTo(size.width-radius, 0);
    path.close();
*/
    path.moveTo(0, 0);
    path.arcToPoint(Offset(0, radius), radius: Radius.circular(radius/2));
//    path.lineTo(0, radius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, radius);
    path.arcToPoint(Offset(size.width, 0), radius: Radius.circular(radius/2));

    path.close();

    return path;
  }

  @override
  bool shouldReclip (VoucherClipper oldClipper) => true;

}

