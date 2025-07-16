import 'package:KABA/src/microservices/kaba_chine/domain/order/repository.dart';

import '../../../../models/CustomerModel.dart';

class PayForDelivery{
  DeliveryRepository repository;
  PayForDelivery(this.repository);
  Future<Map> call(CustomerModel customer, String phoneNumber, String amount,String delivery_id,String paymentMethod) {
    return repository.payForDelivery(customer,phoneNumber, amount,delivery_id,paymentMethod);
  }
}