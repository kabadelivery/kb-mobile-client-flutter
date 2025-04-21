import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/repository.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:rxdart/rxdart.dart';

class UserDataBloc {

  final _repository = Repository();

  /* register - send code */
  final _sendRegisterCodeAction = PublishSubject<int>();
  Stream<int> get sendRegisterCodeGetter => _sendRegisterCodeAction.stream;

  /* dailyOrder */
  final _myDailyOrderFetcher = PublishSubject<List<CommandModel>>();
  Stream<List<CommandModel>> get mDailyOrders => _myDailyOrderFetcher.stream;

  /* last all Order */
  final _myLastOrderFetcher = PublishSubject<List<CommandModel>>();
  Stream<List<CommandModel>> get mLastOrders => _myLastOrderFetcher.stream;

/* order details */
  final _orderDetailsFetcher = PublishSubject<CommandModel>();
  Stream<CommandModel> get orderDetails => _orderDetailsFetcher.stream;

  /* my addresses */
  final _deliveryAddressFetcher = PublishSubject<List<DeliveryAddressModel>>();
  Stream<List<DeliveryAddressModel>> get deliveryAddress => _deliveryAddressFetcher.stream;

  /* vouchers subscriptions */
//  final _subcribedVouchersFetcher = PublishSubject<List<MyVoucherListWidget>>();
//  Observable<List<DeliveryAddressModel>> get subscribedVouchers => _subcribedVouchersFetcher.stream;

  /* check location details */
  final _locationDetailsChecker = PublishSubject<DeliveryAddressModel>();
  Stream<DeliveryAddressModel> get locationDetails => _locationDetailsChecker.stream;

  fetchDailyOrders(CustomerModel customer) async {
    try {
      List<CommandModel> mDailyOrders = await _repository.fetchDailyOrders(customer);
      _myDailyOrderFetcher.sink.add(mDailyOrders);
    } catch (_) {
      _myDailyOrderFetcher.sink.addError(_.toString());
    }
  }

  fetchLastOrders(CustomerModel customer) async {
    try {
      List<CommandModel> mLastOrders = await _repository.fetchLastOrders(customer);
      _myLastOrderFetcher.sink.add(mLastOrders);
    } catch (_) {
      _myLastOrderFetcher.sink.addError(_.toString());
    }
  }

  fetchMyAddresses (UserTokenModel userToken) async {
    try {
      List<DeliveryAddressModel> deliveryAddresses = await _repository.fetchMyAddresses(userToken);
      _deliveryAddressFetcher.sink.add(deliveryAddresses);
    } catch (_) {
      _deliveryAddressFetcher.sink.addError(_.toString());
    }
  }

  fetchOrderDetails (CustomerModel customer, int orderId) async {
    try {
      CommandModel orderDetails = await _repository.fetchOrderDetails(customer, orderId);
      _orderDetailsFetcher.sink.add(orderDetails);
    } catch (_) {
      _orderDetailsFetcher.sink.addError(_.toString());
    }
  }

  /*checkLocationDetails({UserTokenModel userToken, Position position}) async {
    try {
      DeliveryAddressModel deliveryAddressModel = await _repository.checkLocationDetails(userToken, position);
      _locationDetailsChecker.sink.add(deliveryAddressModel);
    } catch (_) {
      _locationDetailsChecker.sink.addError(_.message);
    }
  }*/

 /* sendRegisterCode({String login}) async {
    try {
      *//*int error = await _repository.registerSendingCodeAction(login);*//*
      *//*_locationDetailsChecker.sink.add(deliveryAddressModel);*//*
      _sendRegisterCodeAction.sink.add(error);
    } catch (_) {
      _sendRegisterCodeAction.sink.addError(_.message);
    }
  }*/


  dispose() {
//    _myDailyOrderFetcher.close();
//    _orderDetailsFetcher.close();
//    _deliveryAddressFetcher.close();
//    _locationDetailsChecker.close();
    _sendRegisterCodeAction.close();
  }
}

final userDataBloc = UserDataBloc();