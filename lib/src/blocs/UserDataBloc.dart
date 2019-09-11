import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/repository.dart';
import 'package:rxdart/rxdart.dart';

class UserDataBloc {

  final _repository = Repository();

  /* dailyOrder */
  final _myDailyOrderFetcher = PublishSubject<List<CommandModel>>();
  Observable<List<CommandModel>> get mDailyOrders => _myDailyOrderFetcher.stream;

/* order details */
  final _orderDetailsFetcher = PublishSubject<CommandModel>();
  Observable<CommandModel> get orderDetails => _orderDetailsFetcher.stream;

  /* my addresses */
  final _deliveryAddressFetcher = PublishSubject<List<DeliveryAddressModel>>();
  Observable<List<DeliveryAddressModel>> get deliveryAddress => _deliveryAddressFetcher.stream;


  fetchDailyOrders(UserTokenModel userToken) async {
    try {
      List<CommandModel> mDailyOrders = await _repository.fetchDailyOrders(userToken);
      _myDailyOrderFetcher.sink.add(mDailyOrders);
    } catch (_) {
      _myDailyOrderFetcher.sink.addError(_.message);
    }
  }

  fetchMyAddresses (UserTokenModel userToken) async {
    try {
      List<DeliveryAddressModel> deliveryAddresses = await _repository.fetchMyAddresses(userToken);
      _deliveryAddressFetcher.sink.add(deliveryAddresses);
    } catch (_) {
      _deliveryAddressFetcher.sink.addError(_.message);
    }
  }


  fetchOrderDetails (UserTokenModel userToken, int orderId) async {
    try {
      CommandModel orderDetails = await _repository.fetchOrderDetails(userToken, orderId);
      _orderDetailsFetcher.sink.add(orderDetails);
    } catch (_) {
      _orderDetailsFetcher.sink.addError(_.message);
    }
  }

  dispose() {
    _myDailyOrderFetcher.close();
    _orderDetailsFetcher.close();
    _deliveryAddressFetcher.close();
  }

}

final userDataBloc = UserDataBloc();