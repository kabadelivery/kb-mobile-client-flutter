import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/resources/address_api_provider.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/ui/customwidgets/BouncingWidget.dart';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

import '../../../../../utils/functions/OutOfAppOrder/AddressPicker.dart';

class MyAddressesPage extends StatefulWidget {
  static var routeName = "/MyAddressesPage";

  bool pick;

  CustomerModel customer;

  AddressPresenter presenter;

  List<DeliveryAddressModel> data;

  String gps_location = "";

  List<int> favoriteAddress = [];

  List<DeliveryAddressModel> pureDeliveryAddresses = [];
  int address_type;
  MyAddressesPage(
      {Key key,
      this.presenter,
      this.pick = false,
      this.gps_location /*6.33:3.44*/,
      this.address_type
      })
      : super(key: key);

  @override
  _MyAddressesPageState createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage>
    implements AddressView {
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
      CustomerUtils.getFavoriteAddress().then((value) {
        var favAddresses = value;
        setState(() {
          widget.favoriteAddress = favAddresses;
        });
      });
    });
    super.initState();
    if (widget.gps_location != null && "".compareTo(widget.gps_location) != 0) {
      Timer.run(() {
        _createAddress().then((value) {
          widget.gps_location = "";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          IconButton(
              onPressed: () => _createAddress(),
              icon:
                  Icon(Icons.add_location_sharp, size: 20, color: Colors.white))
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('my_addresses')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
      InkWell(
      splashColor: Colors.white,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10,top: 40),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius:
                  BorderRadius.all(Radius.circular(5)),
                  color:  KColors.mBlue.withAlpha(30)
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(children: <Widget>[
                      BouncingWidget(
                        duration: Duration(milliseconds: 400),
                        scaleFactor: 2,
                        child: Icon(Icons.location_on,
                            size: 28,
                            color: KColors.mBlue

                        ),
                      ),
                    ]),
                    SizedBox(width: 10),
                  wi  Text(
                        "${AppLocalizations.of(context).translate('choose_actual_location')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color:
                            KColors.mBlue

                        ))
                  ])),
          onTap: () {
            CustomerUtils.getCustomer().then((customer)async {
              await determinePosition().then((value)async{
                DeliveryAddressModel old_address  =DeliveryAddressModel();
                for(DeliveryAddressModel adr in widget?.data){
                  if(adr.name==AppLocalizations.of(context).translate('choose_actual_location').toString()){
                    old_address=adr;
                    break;
                  }
                }
                DeliveryAddressModel address = DeliveryAddressModel(
                  id: old_address.id,
                  name:"${AppLocalizations.of(context).translate('choose_actual_location')}",
                  location: "${value.latitude}:${value.longitude}",
                  phone_number:customer.phone_number.toString(),
                  user_id: customer.id.toString(),
                  description: "${AppLocalizations.of(context).translate('this_location')}",
                  quartier: "unknown",
                  near: "near unknown",
                );
                AddressApiProvider api = AddressApiProvider();
                Map jsonData = await api.updateOrCreateAddress(address,customer);
                DeliveryAddressModel choosedAddres = jsonData["address"];
                _pickedAddress(choosedAddres);
              });
            });

          }),
          Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(top: 80),
              child: isLoading
                  ? Center(child: MyLoadingProgressWidget())
                  : (hasNetworkError
                      ? _buildNetworkErrorPage()
                      : hasSystemError
                          ? _buildSysErrorPage()
                          : _buildDeliveryAddressesList())),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,

            child: Container(
              // color: KColors.new_gray,
              padding:
                  EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: KColors.primaryColor,
                              borderRadius: BorderRadius.circular(5)),
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              /*    Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 10),*/
                              Text(
                                  "${AppLocalizations.of(context).translate('create_new_address')}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14))
                            ],
                          ),
                        ),
                        onTap: () => _createAddress()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildDeliveryAddressesList() {
    if (widget.data?.length == null || widget.data?.length == 0) {
      // no size
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(icon: Icon(Icons.location_on, color: Colors.grey)),
          SizedBox(height: 10),
          Text(
              "${AppLocalizations.of(context).translate('sorry_no_location_yet')}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ));
    }

    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
        /*
            SwitchListTile(title: const Text("Bunch of interesting test that im not going to talk too much about.", style: TextStyle(fontSize: 14,color: Colors.grey), textAlign: TextAlign.center), onChanged: (bool value) {setState(() {_canReceiveSharedAddress=(!_canReceiveSharedAddress);});}, value: _canReceiveSharedAddress)
            */
      ]..addAll(List<Widget>.generate(widget.data?.length + 1, (int index) {
              if (index < widget.data?.length)
                return index == 0
                    ? Column(
                        children: [
                          SizedBox(height: 10),
                          widget.data[index].name!=AppLocalizations.of(context).translate('choose_actual_location').toString()?
                          buildAddressListWidgetNew(address: widget.data[index]):Container()
                        ],
                      )
                    : widget.data[index].name!=AppLocalizations.of(context).translate('choose_actual_location').toString()?
                buildAddressListWidgetNew(address: widget.data[index]):Container();
              else
                return Container(height: 100);
            }))),
    );
  }

  buildAddressListWidgetNew({DeliveryAddressModel address}) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 10),
            InkWell(
              onTap: () => _pickedAddress(address),
              onLongPress: () => _startDeleteAddress(address),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: address?.is_favorite
                        ? Colors.yellow.withAlpha(50)
                        : KColors.new_gray,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Utils.capitalize(address?.name),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: KColors.new_black)),
                            SizedBox(height: 5),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Text(
                                  Utils.capitalize(address?.description),
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey)),
                            ),
                            SizedBox(height: 5),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.phone,
                                  color: KColors.primaryColor, size: 18),
                              SizedBox(width: 6),
                              Text(
                                address?.phone_number,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              )
                            ])
                          ]),
                      !widget.pick
                          ? GestureDetector(
                              onTap: () => _addToFavorite(address),
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 10),
                                child: Icon(
                                    address.is_favorite
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_outlined,
                                    color: KColors.primaryYellowColor,
                                    size: 18),
                              ),
                            )
                          : Container()
                    ],
                  )),
            ),
          ],
        ),
        Positioned(
            top: 0,
            right: 10,
            child: InkWell(
              onTap: () => _editAddress(address),
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                padding: EdgeInsets.all(10),
                child: Icon(Icons.edit, color: KColors.mBlue, size: 18),
              ),
            ))
      ],
    );
  }

  buildAddressListWidget({DeliveryAddressModel address}) {
    return Card(
        child: InkWell(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Container(
                        child: Text("${address?.name?.toUpperCase()}",
                            style: TextStyle(
                                color: KColors.new_black.withAlpha(180),
                                fontWeight: FontWeight.bold,
                                fontSize: 18)))),
                IconButton(
                    icon: Icon(FontAwesomeIcons.edit,
                        color: CommandStateColor.shipping),
                    splashColor: Colors.grey,
                    onPressed: () => _editAddress(address)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Text("${address?.description}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ),
                ),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text("${AppLocalizations.of(context).translate('contact')}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: KColors.new_black)),
                    SizedBox(width: 10),
                    Text("${address?.phone_number}",
                        style: TextStyle(
                            fontSize: 16,
                            color: CommandStateColor.delivered,
                            fontWeight: FontWeight.bold))
                  ])
                ]),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    "${AppLocalizations.of(context).translate('address_last_update').toUpperCase()} ${DateTime.fromMillisecondsSinceEpoch(int.parse(address?.updated_at) * 1000).toIso8601String().split(".")[0].replaceAll("T", " ")}",
                    style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
      onTap: () => _pickedAddress(address),
      onLongPress: () => _startDeleteAddress(address),
    ));
  }

  _editAddress(DeliveryAddressModel address) async {
    Map results = await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditAddressPage(
                address: address, presenter: EditAddressPresenter()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));

    /* Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAddressPage(address: address, presenter: EditAddressPresenter()),
      ),
    );*/

    if (results != null && results.containsKey('ok') && results['ok'] == true) {
      if (results.containsKey("createdAddress") != null) {
        if (widget.pick) {
          DeliveryAddressModel tmp = results["createdAddress"];
          Navigator.of(context).pop({'selection': tmp});
        } else {
          widget.presenter.loadAddressList(widget.customer); // maj
        }
      } else {
        // update
        widget.presenter.loadAddressList(widget.customer);
      }
    }
  }

  _pickedAddress(DeliveryAddressModel address) {
    if (widget.pick) Navigator.of(context).pop({'selection': address});
  }

  Future<void> _createAddress() async {
    // when come back update the thing.
    Map results = await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditAddressPage(
                presenter: EditAddressPresenter(),
                gps_location: widget.gps_location),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));

    if (results != null && results.containsKey('ok') && results['ok'] == true) {
      if (results.containsKey("createdAddress") != null) {
        if (widget.pick) {
          DeliveryAddressModel tmp = results["createdAddress"];
          Navigator.of(context).pop({'selection': tmp});
        } else {
          if (widget.customer != null)
            widget.presenter.loadAddressList(widget.customer);
        }
      } else {
        // update
        if (widget.customer != null)
          widget.presenter.loadAddressList(widget.customer);
      }
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
    /* order with favorites at the top */
    // _reorderWithFavorite(deliveryAddresses);
    widget.pureDeliveryAddresses = deliveryAddresses;
    setState(() {
      _reorderWithFavorite(List.from(widget.pureDeliveryAddresses));
    });
  }

  _startDeleteAddress(DeliveryAddressModel address) {
    _showDialog(
        icon: VectorsData.questions,
        message:
            "${AppLocalizations.of(context).translate('are_you_sure_to_delete_address')} (${address?.name?.toUpperCase()})",
        isYesOrNo: true,
        actionIfYes: () => _deleteAddress(address));
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
    if (mounted)
      setState(() {
        this.isLoading = isLoading;
        if (isLoading == true) {
          this.hasNetworkError = false;
          this.hasSystemError = false;
        }
      });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.loadAddressList(widget.customer);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.loadAddressList(widget.customer);
        });
  }

  void _showDialog(
      {var icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              /* icon */
              SizedBox(
                  height: 80,
                  width: 80,
                  child: SvgPicture.asset(
                    icon,
                  )),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    // usually buttons at the bottom of the dialog
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    //
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        if (okBackToHome) {
                          Navigator.of(context).pop({'ok': true});
                          Navigator.of(context).pop({'ok': true});
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ]);
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
      for (int i = 0; i < widget.data?.length; i++) {
        if (widget.data[i].id == address.id) {
          widget.data.removeAt(i);
        }
      }
    if (mounted)
      setState(() {
        widget.data = widget.data;
      });
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  void _reorderWithFavorite(List<DeliveryAddressModel> deliveryAddresses) {
    // reorder delivery addresses or data by making sure the favorites id are above
    List<DeliveryAddressModel> top_data = [];

    List<DeliveryAddressModel> coo = List.from(deliveryAddresses);

    coo?.forEach((element) {
      if (widget.favoriteAddress != null &&
          widget.favoriteAddress.contains(element.id)) {
        deliveryAddresses.remove(element);
        var tmp = element;
        tmp.is_favorite = true;
        top_data.add(tmp);
      } else {
        element.is_favorite = false;
      }
    });

    setState(() {
      widget.data = top_data..addAll(deliveryAddresses);
    });
  }

  _addToFavorite(DeliveryAddressModel address) async {
    /* add to favorite */
    /* save the id and locally in an array of favorite */
    /* each time we load from server we order and then put the favorite on top of the world */
    widget.favoriteAddress = await CustomerUtils.getFavoriteAddress();

    // if address is contained, delete it
    if (widget.favoriteAddress.contains(address.id)) {
      widget.favoriteAddress.remove(address.id);
      await CustomerUtils.saveFavoriteAddress(widget.favoriteAddress);
    } else {
      await CustomerUtils.saveFavoriteAddress([
        address.id,
        ...widget.favoriteAddress
      ]); /* notification to show that notification has been pinned on top */
      /*    ElegantNotification.info(
              toastDuration: Duration(seconds: 5),
              title: Text(
                  "${AppLocalizations.of(context).translate('address_pinned_successfully_short')}"),
              notificationPosition: NotificationPosition.center,
              description: Text(
                  "${AppLocalizations.of(context).translate('address_pinned_successfully_long')}"))
          .show(context);*/
      final snackBar = SnackBar(
        content: Text(
            "${AppLocalizations.of(context).translate('address_pinned_successfully_long')}"),
        action: SnackBarAction(
          label:
              "${AppLocalizations.of(context).translate('ok')}".toUpperCase(),
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    var favAddresses = await CustomerUtils.getFavoriteAddress();
    widget.favoriteAddress = favAddresses;

    setState(() {
      _reorderWithFavorite(List.from(widget.pureDeliveryAddresses));
    });
  }
}
