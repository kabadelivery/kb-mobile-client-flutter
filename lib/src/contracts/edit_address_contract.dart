/* login contract */
import 'dart:convert';

import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/resources/address_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressContract {

  void updateOrCreateAddress (DeliveryAddressModel address, CustomerModel customer){}
}

class EditAddressView {
  void showLoading(bool isLoading) {}
  void modifiedSuccess () {}
  void createdSuccess (DeliveryAddressModel address) {}
  void addressModificationFailure (String message) {}
  void inflateDetails(String addressDetails) {}
  void inflateDescription(String description_details, String suburb) {}
  void showAddressDetailsLoading(bool isLoading) {}
  void showUpdateOrCreatedAddressLoading(bool isLoading) {}
  void createFailure() {}
  void checkLocationDetailsError() {}
  void networkError() {}
}

/* login presenter */
class EditAddressPresenter implements EditAddressContract {

  bool isWorking = false;
  bool isAddressDetailsFetching = false;

  AddressApiProvider provider;
  AppApiProvider appProvider;

  EditAddressView _editAddressView;

  EditAddressPresenter () {
    provider = new AddressApiProvider();
    appProvider = new AppApiProvider();
  }

  @override
  Future updateOrCreateAddress(DeliveryAddressModel address, CustomerModel customer) async {

    if (isWorking)
      return;
    isWorking = true;
    _editAddressView.showUpdateOrCreatedAddressLoading(true);
    try {
      Map res = await provider.updateOrCreateAddress(address, customer);
      int error = res["error"];
      address = res["address"];
      _editAddressView.showUpdateOrCreatedAddressLoading(false);
      if (error == 0)
        _editAddressView.createdSuccess(address);
      else
        _editAddressView.addressModificationFailure("");
      isWorking = false;
    } catch (_) {
      _editAddressView.showUpdateOrCreatedAddressLoading(false);
      /* Transaction failure */
      print("error ${_}");
      if (_ == -2) {
      } else {
      }
      _editAddressView.createFailure();
      isWorking = false;
    }
    isWorking = false;
  }


  set editAddressView(EditAddressView value) {
    _editAddressView = value;
  }

  Future<void> checkLocationDetails(CustomerModel customer, {Position position}) async {

    if (isAddressDetailsFetching)
      return;
    isAddressDetailsFetching = true;
    _editAddressView.showAddressDetailsLoading(true);
    try {
      DeliveryAddressModel deliveryAddress = await appProvider.checkLocationDetails(customer, position);
      String suburb = deliveryAddress?.quartier;
      String description_details = deliveryAddress?.description;
      _editAddressView.showAddressDetailsLoading(false);
      _editAddressView.inflateDescription(description_details, suburb);
      isAddressDetailsFetching = false;
    } catch (_) {
      /* Transaction failure */
      _editAddressView.showAddressDetailsLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _editAddressView.networkError();
      } else {
        _editAddressView.checkLocationDetailsError();
      }
      isAddressDetailsFetching = false;
    }
  }

}
