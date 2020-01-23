/* login contract */
import 'dart:convert';

import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/resources/address_api_provider.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressContract {

  void updateOrCreateAddress (DeliveryAddressModel address, CustomerModel customer){}
}

class AddressView {
  void showLoading(bool isLoading) {}
  void modifiedSuccess () {}
  void createdSuccess () {}
  void addressModificationFailure (String message) {}
}

/* login presenter */
class AddressPresenter implements AddressContract {

  bool isWorking = false;

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

    String jsonContent = await provider.updateOrCreateAddress(address, customer);
    provider.updateOrCreateAddress(address, customer);

    try {
      /*  print(jsonContent);
      var obj = json.decode(jsonContent);

    } else {
     _loginView.loginFailure(message);
    }*/
    } catch(_) {
      /* login failure */

    }
    isWorking = false;
  }

  set editAddressView(AddressView value) {
    _editAddressView = value;
  }

}