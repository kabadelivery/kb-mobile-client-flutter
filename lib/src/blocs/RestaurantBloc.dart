import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class RestaurantBloc {
  final _repository = Repository();

  /* restaurant list fetcher */
  final _restaurantListFetcher = PublishSubject<List<RestaurantModel>>();
  Observable<List<RestaurantModel>> get restaurantList => _restaurantListFetcher.stream;

  /* comment list fetcher */
  final _commentListFetcher = PublishSubject<List<CommentModel>>();
  Observable<List<CommentModel>> get commentList => _commentListFetcher.stream;


  fetchRestaurantList() async {
    try {
      List<RestaurantModel> restaurantList = await _repository.fetchRestaurantList();
      _restaurantListFetcher.sink.add(restaurantList);
    } catch (_) {
      _restaurantListFetcher.sink.addError(_.message);
    }
  }

  fetchCommentList(RestaurantModel restaurantModel) async {
    try {
      List<CommentModel> commentList = await _repository.fetchRestaurantComment(restaurantModel);
      _commentListFetcher.sink.add(commentList);
    } catch (_) {
      _commentListFetcher.sink.addError(_.message);
    }
  }



  dispose() {
    _restaurantListFetcher.close();
    _commentListFetcher.close();
  }

}

final restaurantBloc = RestaurantBloc();