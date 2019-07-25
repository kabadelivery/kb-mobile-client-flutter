import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class RestaurantBloc {
  final _repository = Repository();
  final _restaurantListFetcher = PublishSubject<List<RestaurantModel>>();


  Observable<List<RestaurantModel>> get restaurantList => _restaurantListFetcher.stream;


  fetchRestaurantList() async {
    try {
      List<RestaurantModel> restaurantList = await _repository.fetchRestaurantList();
      _restaurantListFetcher.sink.add(restaurantList);
    } catch (_) {
      _restaurantListFetcher.sink.addError(_.message);
    }
  }


  dispose() {
    _restaurantListFetcher.close();
  }

}

final restaurantBloc = RestaurantBloc();