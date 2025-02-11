import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/CustomerModel.dart';
import '../../models/OrderBillConfiguration.dart';

class OrderBillingState{
  CustomerModel customer;
  OrderBillConfiguration orderBillConfiguration;
  OrderBillingState({this.customer=null,this.orderBillConfiguration=null});

  OrderBillingState copyWith({
    CustomerModel customer,
    OrderBillConfiguration orderBillConfiguration
}){
    return OrderBillingState(
    customer:customer??this.customer,
   orderBillConfiguration: orderBillConfiguration??this.orderBillConfiguration);
}
}

class OrderBillingStateNotifier extends StateNotifier<OrderBillingState>{
  OrderBillingStateNotifier():super(OrderBillingState());

  void setCustomer(CustomerModel customer){
    state = state.copyWith(customer:customer);
  }
  void setOrderBillConfiguration(OrderBillConfiguration orderBillConfiguration){
    state = state.copyWith(orderBillConfiguration:orderBillConfiguration);
  }
}
final orderBillingStateProvider = StateNotifierProvider<OrderBillingStateNotifier,OrderBillingState>((ref){
  return OrderBillingStateNotifier();
});