import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/resources/cinema_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class MovieContract {
  void fetchMovieScheduleWithMovieId(int MovieId) {}
}

class MovieView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void inflateMovieSchedule(ShopModel Movie, List<MovieModel> data) {}
}

class MoviePresenter implements MovieContract {

  bool isWorking = false;

  MovieView _MovieView;

  late CinemaApiProvider provider;

  MoviePresenter(this._MovieView) {
    provider = new CinemaApiProvider();
  }

  set movieView(MovieView value) {
    _MovieView = value;
  }

  @override
  Future<void> fetchMovieScheduleWithMovieId(int MovieId) async {
    if (isWorking) return;
    isWorking = true;
    _MovieView.showLoading(true);
    try {
      Map? res =
          await provider.fetchMovieDetailsWithMovieId(MovieId);
      int menuId = 0;
      // also get the restaurant entity here.
      _MovieView.showLoading(false);
    } catch (_) {
      /* login failure */
      _MovieView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _MovieView.systemError();
      } else {
        _MovieView.networkError();
      }
      isWorking = false;
    }
  }
}
