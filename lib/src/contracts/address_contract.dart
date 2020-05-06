/* login contract */
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/resources/address_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressContract {

  void updateOrCreateAddress (DeliveryAddressModel address, CustomerModel customer){}
}

class AddressView {
  void showLoading(bool isLoading) {}
  void modifiedSuccess () {}
  void createdSuccess () {}
  void addressModificationFailure (String message) {}
  void inflateDetails(String addressDetails) {}
  void inflateDescription(String description_details, String suburb) {}
  void showAddressDetailsLoading(bool isLoading) {}
  void showUpdateOrCreatedAddressLoading(bool isLoading) {}
}

/* login presenter */
class AddressPresenter implements AddressContract {

  bool isWorking = false;
  bool isAddressDetailsFetching = false;

  AddressApiProvider provider;

  AddressView _editAddressView;

  AddressPresenter () {
    provider = new AddressApiProvider();
  }

  @override
  Future updateOrCreateAddress(DeliveryAddressModel address, CustomerModel customer) async {

    if (isWorking)
      return;
    isWorking = true;
    _editAddressView.showUpdateOrCreatedAddressLoading(true);
    try {
      int error = await provider.updateOrCreateAddress(address, customer);
      if (error == 0)
        _editAddressView.createdSuccess();
      else
        _editAddressView.addressModificationFailure("");
      isWorking = false;
    } catch (_) {
      /* Transaction failure */
      print("error ${_}");
      if (_ == -2) {
      } else {
      }
      _editAddressView.createdSuccess();
      isWorking = false;
    }
  }


  set editAddressView(AddressView value) {
    _editAddressView = value;
  }

  Future<void> checkLocationDetails(CustomerModel customer, {Position position}) async {

    if (isAddressDetailsFetching)
      return;
    isAddressDetailsFetching = true;
    _editAddressView.showAddressDetailsLoading(true);
    try {
      Map m = await provider.checkLocationDetails(customer, position);
      String suburb = m["suburb"];
      String description_details = m["description_details"];
      _editAddressView.inflateDescription(description_details, suburb);
      isAddressDetailsFetching = false;
    } catch (_) {
      /* Transaction failure */
      print("error ${_}");
      if (_ == -2) {
//        _editAddressView.();
      } else {
//        _editAddressView.balanceSystemError();
      }
      isAddressDetailsFetching = false;
    }
  }

}
