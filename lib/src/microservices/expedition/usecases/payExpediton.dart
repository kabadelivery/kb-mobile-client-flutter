import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';

import '../../../models/CustomerModel.dart';

class PayExpedition{
  ExpeditionRepository repo;
  PayExpedition(this.repo);
  Future<Map> call(CustomerModel customer, String phoneNumber, String amount,
      String delivery_id,String paymentMethod) {
    return repo.payForDelivery(customer, phoneNumber, amount, delivery_id,paymentMethod);
  }
}