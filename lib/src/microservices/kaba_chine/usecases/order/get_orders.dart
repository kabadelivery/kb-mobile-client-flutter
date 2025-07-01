import '../../data/order/delivery_model.dart';
import '../../domain/order/repository.dart';

class GetDeliveryHistory {
  final DeliveryRepository repository;

  GetDeliveryHistory(this.repository);

  Future<List<Delivery>> call(String userId) {
    return repository.getDeliveryHistory(userId);
  }
}