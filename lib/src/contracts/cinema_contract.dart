import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/resources/cinema_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class CinemaContract {
  void fetchMovieScheduleWithCinemaId(int cinemaId) {}
}

class CinemaView {
  void showLoading(bool isLoading) {}
  void systemError() {}
  void networkError() {}
  void inflateMovieSchedule(ShopModel cinema, List<MovieModel> data) {}
}

class CinemaPresenter implements CinemaContract {
  bool isWorking = false;

  CinemaView _cinemaView;

  late CinemaApiProvider provider;

  CinemaPresenter(this._cinemaView) {
    provider = new CinemaApiProvider();
  }

  set cinemaView(CinemaView value) {
    _cinemaView = value;
  }

  @override
  Future<void> fetchMovieScheduleWithCinemaId(int cinemaId) async {
    if (isWorking) return;
    isWorking = true;
    _cinemaView.showLoading(true);
    try {
      Map? res =
          await provider.fetchMovieScheduleWithCinemaId(cinemaId);
      int menuId = 0;
      // also get the restaurant entity here.
      _cinemaView.showLoading(false);
    } catch (_) {
      /* login failure */
      _cinemaView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _cinemaView.systemError();
      } else {
        _cinemaView.networkError();
      }
      isWorking = false;
    }
  }
}
