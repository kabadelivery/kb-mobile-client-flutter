
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/resources/service_main_provider.dart';
import 'package:KABA/src/xrint.dart';

import '../resources/app_api_provider.dart';

class ServiceMainContract {
  void fetchCategories() {}
}

class ServiceMainView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void checkVersion (String code, int force, String cl_en, String cl_fr, String cl_zh) {}
  void inflateCategories(List<ServiceMainEntity> buy_entity) {}
}


/* Food presenter */
class ServiceMainPresenter implements ServiceMainContract {

  bool isWorking = false;

  ServiceMainView _serviceMainView;

  late ServiceMainApiProvider provider;

  ServiceMainPresenter(this._serviceMainView) {
    provider = new ServiceMainApiProvider();
  }

  set serviceView(ServiceMainView value) {
    _serviceMainView = value;
  }
  @override
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
  @override
  Future fetchCategories() async {
    if (isWorking)
      return;
    isWorking = true;
    _serviceMainView.showLoading(true);
    try {
      // we can fetch with or without gps location, but ... that's for later
      // ShopProductModel foodModel = await provider.fetchServiceCategory();
      // also get the restaurant entity here.
      // _serviceMainView.inflateFood(foodModel);
    } catch (_) {
      /* Food failure */
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