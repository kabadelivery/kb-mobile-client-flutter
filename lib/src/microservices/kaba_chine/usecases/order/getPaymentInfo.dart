import 'package:KABA/src/microservices/kaba_chine/data/order/payment_info_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/order/repository.dart';

import '../../data/order/payment_model.dart';

class GetPaymentInfo{
  final DeliveryRepository repo;
  const GetPaymentInfo(this.repo);
  Future<PaymentInfoModel> call(String deliveryId) {
    return repo.getPaymentInfo(deliveryId);
  }
}