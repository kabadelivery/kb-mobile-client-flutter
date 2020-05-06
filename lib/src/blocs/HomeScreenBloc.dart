import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreenBloc {
  final _repository = Repository();
  final _homeScreenFetcher = PublishSubject<HomeScreenModel>();


  Stream<HomeScreenModel> get homeScreenModel => _homeScreenFetcher.stream;


  fetchHomeScreenModel() async {
    try {
//      HomeScreenModel homeScreenModel = await _repository.fetchHomeScreenModel();
//      _homeScreenFetcher.sink.add(homeScreenModel);
    } catch (_) {
      _homeScreenFetcher.sink.addError(_.message);
    }
  }


  dispose() {
    _homeScreenFetcher.close();
  }

}

final homeScreenBloc = HomeScreenBloc();