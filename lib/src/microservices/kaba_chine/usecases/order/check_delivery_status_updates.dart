import '../../data/order/DeliveryStatusUpdate.dart';
import '../../domain/order/repository.dart';

class CheckDeliveryStatusUpdates {
  final DeliveryRepository repository;

  CheckDeliveryStatusUpdates(this.repository);

  Future<List<DeliveryStatusUpdate>> call(String userId) {
    return repository.checkForStatusUpdates(userId);
  }
}
