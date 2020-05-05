import 'package:geolocator/geolocator.dart';
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class RestaurantBloc {
  final _repository = Repository();

  /* restaurant list fetcher */
  final _restaurantListFetcher = PublishSubject<List<RestaurantModel>>();

  bool _isDisposedForRestaurantList = false;
  bool _isDisposedForRestaurantMenu = false;
  bool _isDisposedForComments = false;


  Stream<List<RestaurantModel>> get restaurantList => _restaurantListFetcher.stream;

  /* restaurant menu fetcher */
  final _restaurantMenuFetcher = PublishSubject<List<RestaurantSubMenuModel>>();
  Stream<List<RestaurantSubMenuModel>> get restaurantMenu => _restaurantMenuFetcher.stream;

  /* comment list fetcher */
  final _commentListFetcher = PublishSubject<List<CommentModel>>();
  Stream<List<CommentModel>> get commentList => _commentListFetcher.stream;



  fetchRestaurantList({Position position}) async {

    try {
//      if (_isDisposedForRestaurantList)
//        return;
      List<RestaurantModel> restaurantList = await _repository.fetchRestaurantList(position);
      _restaurantListFetcher.sink.add(restaurantList);
//      _isDisposedForRestaurantList = true;
    } catch (_) {_restaurantListFetcher.sink.addError(_.message);
    }
  }

  fetchCommentList(RestaurantModel restaurantModel, UserTokenModel userToken) async {
    try {
      if (_isDisposedForComments)
        return;
      List<CommentModel> commentList = await _repository.fetchRestaurantComment(restaurantModel, userToken);
      _commentListFetcher.sink.add(commentList);
     _isDisposedForComments = true;
    } catch (_) {
      _commentListFetcher.sink.addError(_.message);
    }
  }

  fetchRestaurantMenuList(RestaurantModel restaurantModel) async {
    try {
      if (_isDisposedForRestaurantMenu)
        return;
      List<RestaurantSubMenuModel> restaurantMenu = await _repository.fetchRestaurantMenuList(restaurantModel);
      _restaurantMenuFetcher.sink.add(restaurantMenu);
     _isDisposedForRestaurantMenu = true;
    } catch (_) {
      _restaurantListFetcher.sink.addError(_.message);
    }
  }



  dispose() {

    _restaurantListFetcher.close();
    _commentListFetcher.close();
  }

}

final restaurantBloc = RestaurantBloc();