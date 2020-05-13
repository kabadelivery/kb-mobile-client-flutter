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

  void loadAddressList (CustomerModel customer){}
}

class AddressView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateDeliveryAddress(List<DeliveryAddressModel> deliveryAddresses) {}
  void deleteError() {}
  void deleteNetworkError() {}
  void deleteSuccess(DeliveryAddressModel address) {}
}

/* login presenter */
class AddressPresenter implements AddressContract {

  bool isWorking = false;

  AddressApiProvider provider;

  AddressView _addressView;

  AddressPresenter () {
    provider = new AddressApiProvider();
  }


  set addressView(AddressView value) {
    _addressView = value;
  }

  @override
  Future<void> loadAddressList(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _addressView.showLoading(true);
    try {
      List<DeliveryAddressModel> deliverAddresses = await provider.fetchAddressList(customer);
      // also get the restaurant entity here.
      _addressView.showLoading(false);
      _addressView.inflateDeliveryAddress(deliverAddresses);
    } catch (_) {
      /* BestSeller failure */
      _addressView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _addressView.systemError();
      } else {
        _addressView.networkError();
      }
    }
    isWorking = false;
  }

  Future<void> deleteAddress(CustomerModel customer, DeliveryAddressModel address) async {

    if (isWorking)
      return;
    isWorking = true;
    _addressView.showLoading(true);
    try {
      int response = await provider.deleteAddress(customer, address);
      // also get the restaurant entity here.
      _addressView.showLoading(false);
      // if success, remove that one from the list.
      if (response == 0) {
        _addressView.deleteSuccess(address);
      } else {
        _addressView.deleteError();
      }
    } catch (_) {
      /* BestSeller failure */
      _addressView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _addressView.deleteNetworkError();
      } else {
        _addressView.deleteError();
      }
    }
    isWorking = false;
  }


}
