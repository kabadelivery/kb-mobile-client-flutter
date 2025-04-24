import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:geolocator/geolocator.dart';

class ServiceMainContract {
  void fetchServiceCategoryFromLocation(Position location) {}

  void fetchBilling() {}
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
              ?.map((categorie) => ServiceMainEntity.fromJson(categorie))
              ?.toList();
          /* order list by position */
          res!.sort((a, b) => (a.position! - b.position!));
          // also get the restaurant entity here.
          if (!(res != null && res.length > 0)) {
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
            ?.map((categorie) => ServiceMainEntity.fromJson(categorie))
            ?.toList();
        /* order list by position */
        res!.sort((a, b) => (a.position! - b.position!));
        // also get the restaurant entity here.
        if (!(res!.length > 0)) {
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
}
