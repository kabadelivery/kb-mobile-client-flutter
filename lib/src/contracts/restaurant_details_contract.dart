
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/resources/menu_api_provider.dart';

class RestaurantDetailsContract {

  void fetchRestaurantDetailsById(CustomerModel customer, int RestaurantDetailsId) {}
}

class RestaurantDetailsView {
  void showCommentLoading (bool isLoading){}
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateRestaurantDetails(RestaurantModel restaurant) {}
  void inflateComments (List<CommentModel> comments){}
  void commentSystemErrorComment() {}
  void commentNetworkError() {}
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

  Future<void> fetchCommentList(CustomerModel customer, int restaurantId) async {

    if (isCommentWorking)
      return;
    isCommentWorking = true;
    _restaurantDetailsView.showCommentLoading(true);
    try {
      List<CommentModel> comments = await clientProvider.fetchRestaurantComment(RestaurantModel(id: restaurantId), UserTokenModel(token: customer.token));
      // also get the restaurant entity here.
      _restaurantDetailsView.inflateComments(comments);
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

}