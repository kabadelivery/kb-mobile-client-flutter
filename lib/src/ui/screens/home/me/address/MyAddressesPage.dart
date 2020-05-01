import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/contracts/address_contract.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyAddressListWidget.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class MyAddressesPage extends StatefulWidget {

  static var routeName = "/MyAddressesPage";

  bool pick;

  UserTokenModel userTokenModel;

  MyAddressesPage({Key key, this.title, this.pick = false}) : super(key: key);

  final String title;

  @override
  _MyAddressesPageState createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {

  bool _canReceiveSharedAddress = false;

  @override
  void initState() {
    // TODO: implement initState
    CustomerUtils.getUserToken().then((userTokenModel) {
      widget.userTokenModel = userTokenModel;
      userDataBloc.fetchMyAddresses(userTokenModel);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("MY ADDRESSES", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<DeliveryAddressModel>>(
              stream: userDataBloc.deliveryAddress,
              builder:(context, AsyncSnapshot<List<DeliveryAddressModel>> snapshot) {
                if (snapshot.hasData) {
                  return _buildAddressList(snapshot.data);
                } else if (snapshot.hasError) {
                  return ErrorPage(onClickAction: (){ userDataBloc.fetchMyAddresses(widget.userTokenModel);});
                }
                return Center(child: CircularProgressIndicator());
              }
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.add, color: KColors.primaryColor),
                      SizedBox(width: 10),
                      Text("CREER NOUVELLE ADRESSE", style: TextStyle(color: KColors.primaryColor))
                    ],
                  ),
                ), color: KColors.primaryColorTransparentADDTOBASKETBUTTON, onPressed: () => _createAddress()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(List<DeliveryAddressModel> data) {
    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
            /*
            SwitchListTile(title: const Text("Bunch of interesting test that im not going to talk too much about.", style: TextStyle(fontSize: 14,color: Colors.grey), textAlign: TextAlign.center), onChanged: (bool value) {setState(() {_canReceiveSharedAddress=(!_canReceiveSharedAddress);});}, value: _canReceiveSharedAddress)
            */
          ]..addAll(
              List<Widget>.generate(data?.length, (int index) {
                return  buildAddressListWidget(address: data[index]);
              })
          )
      ),
    );
  }

  buildAddressListWidget({DeliveryAddressModel address}) {

    return
      Card(child: InkWell(
        child: Container(padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded (child: Container (child: Text("${address?.name?.toUpperCase()}", style: TextStyle(color: Colors.black.withAlpha(180), fontWeight: FontWeight.bold,fontSize: 18)))),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded (
                    child: Container(padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text("${address?.description}",maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ),
                  IconButton(icon: Icon(FontAwesomeIcons.penFancy, color: CommandStateColor.shipping), splashColor: Colors.grey, onPressed: ()=>_editAddress(address)),
                ],
              ),
              Row(children: <Widget>[Text("Contact", style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16,color:Colors.black)), SizedBox(width: 10),
                Text("${address?.phone_number}", style: TextStyle(fontSize: 16, color: CommandStateColor.delivered, fontWeight: FontWeight.bold))])
            ],
          ),
        ),
        onTap: () => _pickedAddress(address),
      )
      );
  }


  _editAddress(DeliveryAddressModel address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(address: address, presenter: AddressPresenter()),
      ),
    );
  }

  _pickedAddress(DeliveryAddressModel address) {
    if (widget.pick)
      Navigator.of(context).pop({'selection':address});
  }

  _createAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(presenter: AddressPresenter()),
      ),
    );
  }

}

