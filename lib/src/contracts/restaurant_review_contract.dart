
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class RestaurantReviewContract {

  void reviewRestaurant(CustomerModel customerModel, ShopModel restaurant, int stars, String message) {}
}

class RestaurantReviewView {
  void showSendingReviewLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void reviewingSuccess() {}
}


/* RestaurantReview presenter */
class RestaurantReviewPresenter implements RestaurantReviewContract {

  bool isWorking = false;

  RestaurantReviewView _restaurantReviewView;

  MenuApiProvider provider;
  ClientPersonalApiProvider clientProvider;

  RestaurantReviewPresenter() {
    provider = new MenuApiProvider();
  }

  set restaurantReviewView(RestaurantReviewView value) {
    _restaurantReviewView = value;
  }

  @override
  Future reviewRestaurant(CustomerModel customerModel, ShopModel restaurant, int stars, String message) async {
    if (isWorking)
      return;
    isWorking = true;
    _restaurantReviewView.showSendingReviewLoading(true);
    try {
      int error = await provider.reviewRestaurant(customerModel, restaurant, stars, message);
      if (error == 0){
        _restaurantReviewView.showSendingReviewLoading(false);
        _restaurantReviewView.reviewingSuccess();
      } else {
        _restaurantReviewView.systemError();
      }
    } catch (_) {
      /* RestaurantReview failure */
      xrint("error ${_}");
      _restaurantReviewView.showSendingReviewLoading(false);
      if (_ == -2) {
        _restaurantReviewView.systemError();
      } else {
        _restaurantReviewView.networkError();
      }
      isWorking = false;
    }
  }


}