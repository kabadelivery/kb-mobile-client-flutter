import 'package:KABA/src/models/CustomerModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class RestaurantBloc {
  final _repository = Repository();

  /* restaurant list fetcher */
  final _restaurantListFetcher = PublishSubject<List<ShopModel>>();

  bool _isDisposedForRestaurantList = false;
  bool _isDisposedForRestaurantMenu = false;
  bool _isDisposedForComments = false;


  Stream<List<ShopModel>> get restaurantList => _restaurantListFetcher.stream;

  /* restaurant menu fetcher */
  final _restaurantMenuFetcher = PublishSubject<List<RestaurantSubMenuModel>>();
  Stream<List<RestaurantSubMenuModel>> get restaurantMenu => _restaurantMenuFetcher.stream;

  /* comment list fetcher */
  final _commentListFetcher = PublishSubject<List<CommentModel>>();
  Stream<List<CommentModel>> get commentList => _commentListFetcher.stream;



/*  fetchRestaurantList({CustomerModel customer, Position position}) async {

    try {
//      if (_isDisposedForRestaurantList)
//        return;
      List<ShopModel> restaurantList = await _repository.fetchRestaurantList(customer, position);
      _restaurantListFetcher.sink.add(restaurantList);
//      _isDisposedForRestaurantList = true;
    } catch (_) {
      _restaurantListFetcher.sink.addError(_);
    }
  }*/

  /*fetchFoodFromRestaurantByName(String desc) async {

    try {
//      if (_isDisposedForRestaurantList)
//        return;
      List<ShopModel> restaurantList = await _repository.fetchFoodFromRestaurantByName(desc);
      _restaurantListFetcher.sink.add(restaurantList);
//      _isDisposedForRestaurantList = true;
    } catch (_) {
      _restaurantListFetcher.sink.addError(_.message);
    }
  }*/

  fetchCommentList(ShopModel ShopModel, UserTokenModel userToken) async {
    try {
      if (_isDisposedForComments)
        return;
      List<CommentModel> commentList = await _repository.fetchRestaurantComment(ShopModel, userToken);
      _commentListFetcher.sink.add(commentList);
      _isDisposedForComments = true;
    } catch (_) {
      _commentListFetcher.sink.addError(_.toString());
    }
  }

  fetchRestaurantMenuList(ShopModel ShopModel) async {
    try {
      if (_isDisposedForRestaurantMenu)
        return;
      List<RestaurantSubMenuModel> restaurantMenu = await _repository.fetchRestaurantMenuList(ShopModel);
      _restaurantMenuFetcher.sink.add(restaurantMenu);
      _isDisposedForRestaurantMenu = true;
    } catch (_) {
      _restaurantListFetcher.sink.addError(_.toString());
    }
  }

  dispose() {

    _restaurantListFetcher.close();
    _commentListFetcher.close();
  }

}

final restaurantBloc = RestaurantBloc();