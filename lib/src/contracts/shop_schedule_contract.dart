import 'package:KABA/src/models/ShopScheduleModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';

class ShopScheduleContract {
//  void ShopSchedule (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchShopSchedule(int restaurant_id) {}
}

class ShopScheduleView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void inflateShopSchedule(List<ShopScheduleModel> shopSchedule) {}
}

/* ShopSchedule presenter */
class ShopSchedulePresenter implements ShopScheduleContract {
  bool isWorking = false;

  ShopScheduleView _shopScheduleView;

  MenuApiProvider provider;

  ShopSchedulePresenter() {
    provider = new MenuApiProvider();
  }

  set shopScheduleView(ShopScheduleView value) {
    _shopScheduleView = value;
  }

  @override
  Future fetchShopSchedule(int restaurant_id) async {
    /* fetch the one store in the local file first */

    if (isWorking) return;
    isWorking = true;

    CustomerUtils.getOldShopSchedulePage(restaurant_id).then((pageJson) async {
      _shopScheduleView.showLoading(true);
      try {
        if (pageJson != null) {
          Iterable lo = mJsonDecode(pageJson)["data"]["content"];
          List<ShopScheduleModel> ShopSchedules =
              lo?.map((bs) => ShopScheduleModel.fromJson(bs))?.toList();
          /* send these to json */
          _shopScheduleView.inflateShopSchedule(ShopSchedules);
        } else {
          _shopScheduleView.showLoading(true);
        }
      } catch (_) {
        xrint(_);
      }

      try {
        String schedule_json = await provider.fetchShopScheduleList(restaurant_id);
        // save best seller json
        // also get the restaurant entity here.
        Iterable lo = mJsonDecode(schedule_json)["data"]["content"];
        List<ShopScheduleModel> ShopSchedules =
            lo?.map((bs) => ShopScheduleModel.fromJson(bs))?.toList();
        /* send these to json */
        CustomerUtils.saveShopSchedulePage(restaurant_id, schedule_json);
        _shopScheduleView.inflateShopSchedule(ShopSchedules);
        isWorking = false;
      } catch (_) {
        /* ShopSchedule failure */
        xrint("error ${_}");
        if (_ == -2) {
          _shopScheduleView.systemError();
        } else {
          _shopScheduleView.networkError();
        }
        isWorking = false;
      }
    });
  }
}
