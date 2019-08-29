import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/ui/customwidgets/CustomSwitchPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


class OrderConfirmationPage extends StatefulWidget {

  static var routeName = "/OrderConfirmationPage";

  OrderConfirmationPage({Key key}) : super(key: key);


  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {



  Widget _pay_prepayed_switch = CustomSwitchPage(button_1_name: "PRE-ORDER", button_2_name: "PAY NOW", active_text_color: Colors.white, unactive_text_color: Colors.white, active_button_color: KColors.primaryYellowColor, unactive_button_color: KColors.primaryColor);

  DateTime _pre_order_date = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
          backgroundColor: Colors.black,
          title: Text("ok")
      ),
      body: SingleChildScrollView (

        child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Prix Commande", style: TextStyle(color: Colors.black, fontSize: 14)),
                  Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                    IconButton(icon:Icon(Icons.attach_money, color: KColors.primaryColor), onPressed: () {},),
                    Text("3.500 F", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
                  ])
                ],
              ),
              SizedBox(height: 10),

              /*     Container(padding: EdgeInsets.only(top:10, bottom: 10, right: 15, left: 15), decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(const  Radius.circular(40.0)),
                border: new Border.all(color: KColors.primaryColor, width: 1),
              ), child: Row(mainAxisSize: MainAxisSize.min,children: <Widget>[Text("Prix Commmande", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) ,SizedBox(width: 10),
                Text("3.500FCFA", style: TextStyle(color: KColors.primaryYellowColor, fontWeight: FontWeight.bold, fontSize: 18))])),

              SizedBox(height: 10),*/

              Container(
                color: Colors.transparent,
                child: Container(
                    child: _pay_prepayed_switch
                ),
              ),
            ]..addAll( _preorderLayout())
        ),
      ),
    );
  }

  _preorderLayout() {

    return <Widget>[

      SizedBox(height: 20),

      InkWell(
          splashColor: Colors.red,
          child:Container(padding: EdgeInsets.only(top:5,bottom: 5), color: Colors.white,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                Text("Choisir heure de Livraison", style: TextStyle(color:KColors.primaryColor)),
                Row(children: <Widget>[
                  Text("${_pre_order_date.hour < 10 ? "0": ""}${_pre_order_date.hour} : ${_pre_order_date.minute < 10 ? "0": ""}${_pre_order_date.minute}", style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: null),
                ])
              ])), onTap: (){_pickDateTime();}
      ),
      SizedBox(height: 10),
      InkWell(
          splashColor: Colors.red,
          child:Container(padding: EdgeInsets.only(top:5,bottom: 5), color: Colors.white,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                Text("Choisir l'adresse de Livraison", style: TextStyle(color:KColors.primaryColor)),
                Row(children: <Widget>[
                  IconButton(icon: Icon(Icons.my_location, color: KColors.primaryColor), onPressed: null),
                ])
              ])), onTap: (){_pickDeliveryAddress();}
      ),

    ];

  }

  void _pickDateTime() {
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        onChanged: (date) {
//          print('change $date');
        }, onConfirm: (date) {
          setState(() {
            /* fix constraints relative to the preoder date. */
            _pre_order_date = date;
          });
        }, currentTime: DateTime.now(),
        locale: LocaleType.fr);
  }

  void _pickDeliveryAddress() {


  }


}
