import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/resources/cinema_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class ServiceMainContract {
  void fetchServiceCategoryFromLocation(String location) {}
}

class ServiceMainView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void inflateServiceCategory(List<ServiceMainEntity> data) {}
}

class ServiceMainPresenter implements ServiceMainContract {
  bool isWorking = false;

  ServiceMainView _serviceMainView;

  AppApiProvider provider;

  ServiceMainPresenter() {
    provider = new AppApiProvider();
  }

  set movieView(ServiceMainView value) {
    _serviceMainView = value;
  }

  @override
  Future<void> fetchServiceCategoryFromLocation(String location) async {
    if (isWorking) return;
    isWorking = true;
    _serviceMainView.showLoading(true);
    try {
      List<ServiceMainEntity> res =
          await provider.fetchServiceCategoryFromLocation(location);
      // also get the restaurant entity here.
      if (!(res?.length > 0)) {
        throw UnimplementedError();
      }
      _serviceMainView.inflateServiceCategory(res);
      _serviceMainView.showLoading(false);
    } catch (_) {
      /* login failure */
      _serviceMainView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _serviceMainView.systemError();
      } else {
        _serviceMainView.networkError();
      }
      isWorking = false;
    }
  }

}
