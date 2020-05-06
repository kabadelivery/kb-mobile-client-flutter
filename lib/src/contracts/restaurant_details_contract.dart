
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/resources/menu_api_provider.dart';

class RestaurantDetailsContract {

  void fetchRestaurantDetailsById(CustomerModel customer, int restaurantId) {}
  void checkCanComment(CustomerModel customer, RestaurantModel restaurant) {}
}

class RestaurantDetailsView {
  void showCommentLoading (bool isLoading){}
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateRestaurantDetails(RestaurantModel restaurant) {}
  void inflateComments (List<CommentModel> comments, String stars, String votes){}
  void commentSystemErrorComment() {}
  void commentNetworkError() {}

  void showCanCommentLoading(bool isLoading) {}
  void canComment(int canComment) {}
}


/* RestaurantDetails presenter */
class RestaurantDetailsPresenter implements RestaurantDetailsContract {

  bool isWorking = false, isCommentWorking = false;

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
    if (isWorking)
      return;
    isWorking = true;
    _restaurantDetailsView.showLoading(true);
    try {
      RestaurantModel restaurantModel = await provider.fetchRestaurantWithId(customer, restaurantDetailsId);
      // also get the restaurant entity here.
      if (restaurantModel != null)
      _restaurantDetailsView.inflateRestaurantDetails(restaurantModel);
      else
        _restaurantDetailsView.systemError();
    } catch (_) {
      /* RestaurantDetails failure */
      print("error ${_}");
      if (_ == -2) {
        _restaurantDetailsView.systemError();
      } else {
        _restaurantDetailsView.networkError();
      }
      isWorking = false;
    }
  }

  Future<void> fetchCommentList(CustomerModel customer, RestaurantModel restaurant) async {

    if (isCommentWorking)
      return;
    isCommentWorking = true;
    _restaurantDetailsView.showCommentLoading(true);
    try {
     Map res = await clientProvider.fetchRestaurantComment(restaurant, UserTokenModel(token: customer.token));
      // also get the restaurant entity here.
      List<CommentModel> comments = res["comments"];
      String stars = res["stars"];
     String votes = res["votes"];
      _restaurantDetailsView.inflateComments(comments, stars, votes);
    } catch (_) {
      /* Feed failure */
      print("error ${_}");
      if (_ == -2) {
        _restaurantDetailsView.commentSystemErrorComment();
      } else {
        _restaurantDetailsView.commentNetworkError();
      }
      isCommentWorking = false;
    }
  }

  @override
  Future<void> checkCanComment(CustomerModel customer, RestaurantModel restaurant) async {
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
      _restaurantDetailsView.showCanCommentLoading(true);
    } catch (_) {
      /* RestaurantReview failure */
      print("error ${_}");
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