import 'package:KABA/src/microservices/kaba_chine/domain/order/repository.dart';

import '../../../../models/CustomerModel.dart';

class PayForDelivery{
  DeliveryRepository repository;
  PayForDelivery(this.repository);
  Future<Map> call(CustomerModel customer, String phoneNumber, String balance, double fees,String delivery_id) {
    return repository.payForDelivery(customer,phoneNumber, balance, fees,delivery_id);
  }
}