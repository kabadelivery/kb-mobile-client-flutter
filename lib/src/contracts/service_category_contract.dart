import 'package:KABA/src/models/DeliveryRatingPending.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../models/CustomerModel.dart';
import '../utils/functions/new_rating_feature.dart';

class ServiceMainContract {
  void fetchServiceCategoryFromLocation(Position location) {}

  void fetchBilling() {}
}

class ServiceMainView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}
  void checkVersion (String code, int force, String cl_en, String cl_fr, String cl_zh) {}
  void showOrderRating (List<DeliveryRatingPending> deliveryRatingPending) {}
  void getRating(bool gotData){}
  void inflateServiceCategory(List<ServiceMainEntity> data) {}

}

class ServiceMainPresenter implements ServiceMainContract {
  bool isWorking = false;

  ServiceMainView _serviceMainView;

  late AppApiProvider provider;

  ServiceMainPresenter(this._serviceMainView) {
    provider = new AppApiProvider();
  }

  set serviceMainView(ServiceMainView value) {
    _serviceMainView = value;
  }

  @override
  Future<void> fetchServiceCategoryFromLocation(Position? location) async {
    if (isWorking) return;
    isWorking = true;

    _serviceMainView.showLoading(true);
    CustomerUtils.getOldCategoryConfiguration().then((pageJson) async {
      try {
        if (pageJson != null) {
          Iterable lo = mJsonDecode(pageJson)["data"];
          List<ServiceMainEntity>? res = lo
              .map((categorie) => ServiceMainEntity.fromJson(categorie))
              .toList();
          /* order list by position */
          res!.sort((a, b) => (a.position! - b.position!));
          // also get the restaurant entity here.
          if (!(res.length > 0)) {
            throw UnimplementedError();
          }
          _serviceMainView.inflateServiceCategory(res);
          _serviceMainView.showLoading(false);
        } else {
          _serviceMainView.showLoading(true);
        }
      } catch (_) {
        xrint(_);
        _serviceMainView.showLoading(true);
      }

      try {
        String resJson =
        await provider.fetchServiceCategoryFromLocation(location!);
        Iterable lo = mJsonDecode(resJson)["data"];
        List<ServiceMainEntity>? res = lo
            .map((categorie) => ServiceMainEntity.fromJson(categorie))
            .toList();
        /* order list by position */
        res!.sort((a, b) => (a.position! - b.position!));
        // also get the restaurant entity here.
        if (!(res.length > 0)) {
          throw UnimplementedError();
        }

        CustomerUtils.saveCategoryConfiguration(resJson);
        _serviceMainView.inflateServiceCategory(res);
        _serviceMainView.showLoading(false);
        isWorking = false;
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
      isWorking = false;
    });
  }

  @override
  Future<void> fetchBilling() async {
    try {
      String billing = await provider.fetchBilling();
      CustomerUtils.updateBillingLocally(billing);
    } catch (_) {
      xrint("error ${_}");
    }
  }

  Future<void> checkVersion() async {
    try {
      AppApiProvider provider = AppApiProvider();
      Map version = await provider.checkVersion();
      String code = version["version"];
      int force = version["is_required"];
      String cl_en = version["changeLog"]["en"];
      String cl_fr = version["changeLog"]["fr"];
      String cl_zh = version["changeLog"]["zh"];
      _serviceMainView.checkVersion(code, force, cl_en, cl_fr, cl_zh);
    } catch (_) {
      /* RestaurantReview failure */
      xrint("error ${_}");
    }
  }
  Future<void> showOrderRating() async {

    try {
      List<DeliveryRatingPending>? ordersRating = await getRatePendingFromCache();
      List<DeliveryRatingPending>? deliveriesRatingPending=[];
      if(ordersRating==null || ordersRating.isEmpty){
        _serviceMainView.showOrderRating([]);
      }
      CustomerModel customer = await CustomerUtils.getCustomer();
      for(DeliveryRatingPending orderRating in ordersRating??[]){
        try{
          DeliveryRatingPending deliveryRatingPending   = await provider.getcommandDeliveryManRate(customer: customer, command_id: orderRating.command_id.toString());
          deliveryRatingPending.foods=orderRating.foods;
          deliveryRatingPending.restaurant=orderRating.restaurant;
          deliveryRatingPending.address=orderRating.address;
          if(deliveryRatingPending.command_id==0){
            continue;
          }else{
            deliveriesRatingPending.add(deliveryRatingPending);
          }
        }catch(_){
          xrint("error fetching rating for order ${orderRating.command_id} : ${_}");
        }
      }
      if(deliveriesRatingPending!=null){
        _serviceMainView.showOrderRating(deliveriesRatingPending);
      }
    } catch (_) {
      xrint("error ${_}");
    }

  }
  Future<void> getRating() async {
    try {
      var result = await provider.getAppPerformance(); // could be null
      if (result == null) {
        debugPrint("getAppPerformance returned null");
        _serviceMainView.getRating(false);
        return;
      }
      Map<String, dynamic> performance = Map<String, dynamic>.from(result);
      Utils.saveAppPerformance(performance);
      _serviceMainView.getRating(true);
    } catch (e) {
      debugPrint("error fetching performance $e");
      _serviceMainView.getRating(false);
    }
  }

}
