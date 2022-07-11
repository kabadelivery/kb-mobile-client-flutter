import 'package:KABA/src/models/EvenementModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class EvenementContract {

//  void Evenement (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchEvenements() {}
}

class EvenementView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateEvenement(List<EvenementModel> events) {}
}


/* Evenement presenter */
class EvenementPresenter implements EvenementContract {

  bool isWorking = false;

  EvenementView _evenementView;

  AppApiProvider provider;

  EvenementPresenter() {
    provider = new AppApiProvider();
  }

  set evenementView(EvenementView value) {
    _evenementView = value;
  }

  @override
  Future fetchEvenements() async {
    if (isWorking)
      return;
    isWorking = true;
    _evenementView.showLoading(true);
    try {
      List<EvenementModel> evenements = await provider.fetchEvenementList();
      // also get the restaurant entity here.
      _evenementView.inflateEvenement(evenements);
    } catch (_) {
      /* Evenement failure */
      xrint("error ${_}");
      if (_ == -2) {
        _evenementView.systemError();
      } else {
        _evenementView.networkError();
      }
      isWorking = false;
    }
  }

}