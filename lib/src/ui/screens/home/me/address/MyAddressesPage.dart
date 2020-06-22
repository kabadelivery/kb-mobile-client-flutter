import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/ui/customwidgets/MyAddressListWidget.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';


class MyAddressesPage extends StatefulWidget {

  static var routeName = "/MyAddressesPage";

  bool pick;

  CustomerModel customer;

  AddressPresenter presenter;

  List<DeliveryAddressModel> data;

  MyAddressesPage({Key key, this.presenter, this.pick = false}) : super(key: key);


  @override
  _MyAddressesPageState createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> implements AddressView {

  bool _canReceiveSharedAddress = false;
  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;


  @override
  void initState() {

    widget.presenter.addressView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.loadAddressList(customer);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("${AppLocalizations.of(context).translate('my_addresses')}", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildDeliveryAddressesList())
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
                      Text("${AppLocalizations.of(context).translate('create_new_address')}", style: TextStyle(color: KColors.primaryColor))
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

  _buildDeliveryAddressesList () {

    if (widget.data?.length == null || widget.data?.length == 0){
      // no size
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.location_on, color: Colors.grey)),
              SizedBox(height: 10),
              Text("${AppLocalizations.of(context).translate('sorry_no_location_yet')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ));
    }

    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
            /*
            SwitchListTile(title: const Text("Bunch of interesting test that im not going to talk too much about.", style: TextStyle(fontSize: 14,color: Colors.grey), textAlign: TextAlign.center), onChanged: (bool value) {setState(() {_canReceiveSharedAddress=(!_canReceiveSharedAddress);});}, value: _canReceiveSharedAddress)
            */
          ]..addAll(
              List<Widget>.generate(widget.data?.length+1, (int index) {
                if (index < widget.data?.length)
                  return buildAddressListWidget(address: widget.data[index]);
                else
                  return Container(height: 100);
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
              Row(children: <Widget>[Text("${AppLocalizations.of(context).translate('contact')}", style: TextStyle(fontWeight: FontWeight.normal,fontSize: 16,color:Colors.black)), SizedBox(width: 10),
                Text("${address?.phone_number}", style: TextStyle(fontSize: 16, color: CommandStateColor.delivered, fontWeight: FontWeight.bold))])
            ],
          ),
        ),
        onTap: () => _pickedAddress(address),
        onLongPress: () => _startDeleteAddress(address),
      )
      );
  }

  _editAddress(DeliveryAddressModel address) async {

    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(address: address, presenter: EditAddressPresenter()),
      ),
    );
    if (results != null && results.containsKey('ok') && results['ok'] == true) {
      // update
      widget.presenter.loadAddressList(widget.customer);
    }
  }

  _pickedAddress(DeliveryAddressModel address) {
    if (widget.pick)
      Navigator.of(context).pop({'selection':address});
  }

  _createAddress() async {

    // when come back update the thing.
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(presenter: EditAddressPresenter()),
      ),
    );

    if (results != null && results.containsKey('ok') && results['ok'] == true) {
      // update
      if (widget.customer != null)
        widget.presenter.loadAddressList(widget.customer);
    }
  }


  _deleteAddress(DeliveryAddressModel address) {

    if (widget.customer != null) {
      widget.presenter.deleteAddress(widget.customer, address);
    }
  }


  @override
  void inflateDeliveryAddress(List<DeliveryAddressModel> deliveryAddresses) {
    //
    setState(() {
      widget.data = deliveryAddresses;
    });
  }

  _startDeleteAddress(DeliveryAddressModel address) {

    _showDialog(
        icon: VectorsData.questions,
        message: "${AppLocalizations.of(context).translate('are_you_sure_to_delete_address')} (${address?.name})",
        isYesOrNo: true,
        actionIfYes: () => _deleteAddress(address)
    );
  }

  @override
  void networkError() {
    setState(() {
      hasNetworkError = true;
    });
  }


  @override
  void systemError() {
    setState(() {
      hasSystemError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.loadAddressList(widget.customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){ widget.presenter.loadAddressList(widget.customer); });
  }

  void _showDialog({var icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /* icon */
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                        icon,
                      )),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              // usually buttons at the bottom of the dialog
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color:Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text("accept", style: TextStyle(color:KColors.primaryColor)),
                onPressed: (){
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              //
              OutlineButton(
                child: new Text("${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color:KColors.primaryColor)),
                onPressed: () {
                  if (okBackToHome){
                    Navigator.of(context).pop({'ok':true});
                    Navigator.of(context).pop({'ok':true});
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ]
        );
      },
    );
  }

  @override
  void deleteError() {
    mToast("${AppLocalizations.of(context).translate('delete_error')}");
  }

  @override
  void deleteNetworkError() {
    mToast("${AppLocalizations.of(context).translate('delete_network_error')}");
  }

  @override
  void deleteSuccess(DeliveryAddressModel address) {
    if (widget.data != null && widget.data?.length > 0)
      for(int i = 0; i < widget.data?.length; i++) {
        if (widget.data[i].id == address.id){
          widget.data.removeAt(i);
        }
      }
    setState(() {
      widget.data = widget.data;
    });
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

}

