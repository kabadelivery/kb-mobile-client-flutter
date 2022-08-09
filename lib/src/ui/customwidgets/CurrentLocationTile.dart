import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/plus_code/open_location_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationTile extends StatefulWidget {
  CustomerModel customer;

  CurrentLocationTile({Key key}) : super(key: key);

  @override
  _CurrentLocationTileState createState() {
    return _CurrentLocationTileState();
  }
}

class _CurrentLocationTileState extends State<CurrentLocationTile> {
  @override
  void initState() {
    super.initState();

    CustomerUtils.getCustomer().then((customer) {
      if (customer != null) {
        widget.customer = customer;
        CustomerUtils.getSavedAddressLocally().then((value) {
          setState(() {
            StateContainer.of(context).selectedAddress = value;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    //   load delivery address model if exists and if user is logged
  }

  _locationToPlusCode(Position location) {
    return encode(location.latitude, location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: StateContainer?.of(context)?.location != null ||
              StateContainer.of(context).selectedAddress != null
          ? Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  color: KColors.mBlue.withAlpha(10),
                  borderRadius: BorderRadius.circular(5)),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          child: Icon(Icons.location_on,
                              color: KColors.mBlue, size: 15),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KColors.mBlue.withAlpha(30)),
                          padding: EdgeInsets.all(5)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            child: Text(
                                Utils.capitalize(
                                    "${StateContainer.of(context).selectedAddress?.name}"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: KColors.new_black)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            child: RichText(
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: Utils.capitalize(
                                    "${AppLocalizations.of(context).translate('near_by')} - "),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                children: [
                                  TextSpan(
                                      text: Utils.capitalize(
                                          "${StateContainer.of(context).selectedAddress?.near}"),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "${_locationToPlusCode(StateContainer.of(context).location)}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                      child: Icon(FontAwesome.chevron_down,
                          color: KColors.primaryColor, size: 10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KColors.primaryColor.withAlpha(30)),
                      padding: EdgeInsets.all(5)),
                ],
              ),
            )
          : Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 15),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  color: KColors.mBlue.withAlpha(10),
                  borderRadius: BorderRadius.circular(5)),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          child: Icon(Icons.location_on,
                              color: KColors.mBlue, size: 15),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KColors.mBlue.withAlpha(30)),
                          padding: EdgeInsets.all(5)),
                      SizedBox(width: 10),
                      Text(
                          Utils.capitalize(
                              "${AppLocalizations.of(context).translate('please_select_main_location')}"),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey)),
                    ],
                  ),
                  Container(
                      child: Icon(Icons.add,
                          color: KColors.primaryColor, size: 15),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KColors.primaryColor.withAlpha(30)),
                      padding: EdgeInsets.all(5)),
                ],
              ),
            ),
      onTap: () => {_pickMyAddress()},
    );
  }

  _pickMyAddress() async {
    /* jump and get it */
    Map results = await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyAddressesPage(pick: true, presenter: AddressPresenter()),
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

    if (results != null && results.containsKey('selection')) {
      setState(() {
        StateContainer.of(context).selectedAddress = results['selection'];
        StateContainer.of(context).selectedAddress =
            StateContainer.of(context).selectedAddress;
        /* must save this location locally */
        String latitude =
            StateContainer.of(context).selectedAddress.location.split(":")[0];
        String longitude =
            StateContainer.of(context).selectedAddress.location.split(":")[1];
        StateContainer.of(context).location = Position(
            latitude: double.parse(latitude),
            longitude: double.parse(longitude));
      });
      CustomerUtils.saveAddressLocally(
          StateContainer.of(context).selectedAddress);
    }
  }
}
