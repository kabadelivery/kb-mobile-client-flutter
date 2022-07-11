
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/resources/service_main_provider.dart';
import 'package:KABA/src/xrint.dart';

class ServiceMainContract {

  void fetchCategories() {}
}

class ServiceMainView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateCategories(List<ServiceMainEntity> buy_entity) {}
}


/* Food presenter */
class ServiceMainPresenter implements ServiceMainContract {

  bool isWorking = false;

  ServiceMainView _serviceMainView;

  ServiceMainApiProvider provider;

  ServiceMainPresenter() {
    provider = new ServiceMainApiProvider();
  }

  set serviceView(ServiceMainView value) {
    _serviceMainView = value;
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