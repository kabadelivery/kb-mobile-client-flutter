import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyAddressListWidget.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class MyAddressesPage extends StatefulWidget {

  static var routeName = "/MyAddressesPage";

  MyAddressesPage({Key key, this.title}) : super(key: key);

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
      userDataBloc.fetchMyAddresses(userTokenModel);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("MY ADDRESSES", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: StreamBuilder<List<DeliveryAddressModel>>(
          stream: userDataBloc.deliveryAddress,
          builder:(context, AsyncSnapshot<List<DeliveryAddressModel>> snapshot) {
            if (snapshot.hasData) {
              return _buildAddressList(snapshot.data);
            } else if (snapshot.hasError) {
              return ErrorPage(onClickAction: (){ userDataBloc.fetchMyAddresses(UserTokenModel.fake());});
            }
            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }

  Widget _buildAddressList(List<DeliveryAddressModel> data) {
    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
            SwitchListTile(title: const Text("Bunch of interesting test that im not going to talk too much about.", style: TextStyle(fontSize: 14,color: Colors.grey), textAlign: TextAlign.center), onChanged: (bool value) {setState(() {_canReceiveSharedAddress=(!_canReceiveSharedAddress);});}, value: _canReceiveSharedAddress)
          ]..addAll(
              List<Widget>.generate(data?.length, (int index) {
                return MyAddressListWidget(address: data[index]);
              })
          )
      ),
    );
  }
}
