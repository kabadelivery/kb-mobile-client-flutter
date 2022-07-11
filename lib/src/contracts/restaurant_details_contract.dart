
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class RestaurantDetailsContract {

  void fetchRestaurantDetailsById(CustomerModel customer, int restaurantId) {}
  void checkCanComment(CustomerModel customer, ShopModel restaurant) {}
}

class RestaurantDetailsView {
  void showCommentLoading (bool isLoading){}
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateRestaurantDetails(ShopModel restaurant) {}
  void inflateComments (List<CommentModel> comments, String stars, String votes){}
  void commentSystemErrorComment() {}
  void commentNetworkError() {}

  void showCanCommentLoading(bool isLoading) {}
  void canComment(int canComment) {}
}


/* RestaurantDetails presenter */
class RestaurantDetailsPresenter implements RestaurantDetailsContract {

  bool isWorking = false, isCommentWorking = false, isFetchRestaurantDetailsWorking = false;

  RestaurantDetailsView _restaurantDetailsView;

  MenuApiProvider provider;
  ClientPersonalApiProvider clientProvider;

  RestaurantDetailsPresenter() {
    provider = new MenuApiProvider();
    clientProvider = new ClientPersonalApiProvider();
  }

  set restaurantDetailsView(RestaurantDetailsView value) {
    _restaurantDetailsView = value;
  }

  @override
  Future fetchRestaurantDetailsById(CustomerModel customer, int restaurantDetailsId) async {
    if (isFetchRestaurantDetailsWorking)
      return;
    isFetchRestaurantDetailsWorking = true;
    _restaurantDetailsView.showLoading(true);
    try {
      ShopModel restaurantModel = await provider.fetchRestaurantWithId(customer, restaurantDetailsId);
      // also get the restaurant entity here.
      if (restaurantModel != null)
        _restaurantDetailsView.inflateRestaurantDetails(restaurantModel);
      else
        _restaurantDetailsView.systemError();
    } catch (_) {
      /* RestaurantDetails failure */
      xrint("error ${_}");
      if (_ == -2) {
        _restaurantDetailsView.systemError();
      } else {
        _restaurantDetailsView.networkError();
      }
    }
    isFetchRestaurantDetailsWorking = false;
  }

  Future<void> fetchCommentList(CustomerModel customer, ShopModel restaurant) async {

    if (isCommentWorking)
      return;
    isCommentWorking = true;
    _restaurantDetailsView.showCommentLoading(true);
    try {
      Map res = await clientProvider.fetchRestaurantComment(restaurant, UserTokenModel(token: customer?.token));
      // also get the restaurant entity here.
      List<CommentModel> comments = res["comments"];
      String stars = res["stars"];
      String votes = res["votes"];
      _restaurantDetailsView.showCommentLoading(false);
      _restaurantDetailsView.inflateComments(comments, stars, votes);
    } catch (_) {
      /* Feed failure */
      _restaurantDetailsView.showCommentLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _restaurantDetailsView.commentSystemErrorComment();
      } else {
        _restaurantDetailsView.commentNetworkError();
      }
    }
    isCommentWorking = false;
  }

  @override
  Future<void> checkCanComment(CustomerModel customer, ShopModel restaurant) async {
    if (isWorking)
      return;
    isWorking = true;
    _restaurantDetailsView.showCanCommentLoading(true);
    try {
      int can_comment = await provider.checkCanComment(customer, restaurant);
      if (can_comment == 1){
        _restaurantDetailsView.canComment(1);
      } else {
        _restaurantDetailsView.canComment(0);
      }
      _restaurantDetailsView.showCanCommentLoading(false);
    } catch (_) {
      /* RestaurantReview failure */
      xrint("error ${_}");
      _restaurantDetailsView.showCanCommentLoading(false);
      if (_ == -2) {
        _restaurantDetailsView.canComment(0);
      } else {
        _restaurantDetailsView.canComment(0);
      }
      isWorking = false;
    }
  }

}