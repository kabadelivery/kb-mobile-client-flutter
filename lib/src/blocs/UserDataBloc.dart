import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class UserDataBloc {

  final _repository = Repository();

  final _myDailyOrderFetcher = PublishSubject<List<CommandModel>>();

  Observable<List<CommandModel>> get mDailyOrders => _myDailyOrderFetcher.stream;


  fetchDailyOrders(UserTokenModel userToken) async {
    try {
      List<CommandModel> mDailyOrders = await _repository.fetchDailyOrders(userToken);
      _myDailyOrderFetcher.sink.add(mDailyOrders);
    } catch (_) {
      _myDailyOrderFetcher.sink.addError(_.message);
    }
  }


  dispose() {
    _myDailyOrderFetcher.close();
  }

}

final userDataBloc = UserDataBloc();