import '../../data/order/delivery_model.dart';
import '../../domain/order/repository.dart';

class CreateDeliveryRequest {
  final DeliveryRepository repository;

  CreateDeliveryRequest(this.repository);

  Future<Delivery> call(Delivery delivery) {
    return repository.createDeliveryRequest(delivery);
  }
}