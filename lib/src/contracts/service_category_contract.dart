import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/xrint.dart';
import 'package:geolocator/geolocator.dart';

class ServiceMainContract {
  void fetchServiceCategoryFromLocation(Position location) {}
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

  set serviceMainView(ServiceMainView value) {
    _serviceMainView = value;
  }

  @override
  Future<void> fetchServiceCategoryFromLocation(Position location) async {
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
