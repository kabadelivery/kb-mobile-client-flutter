import '../../../../models/CustomerModel.dart';
import '../../data/order/DeliveryStatusUpdate.dart';
import '../../data/order/data_remote_source.dart';
import '../../data/order/delivery_model.dart';
import '../../data/order/payment_info_model.dart';

abstract class DeliveryRepository {
  Future<Delivery> createDeliveryRequest(Delivery delivery);
  Future<String> uploadImage(String imagePath, {String type = 'proof'});
  Future<List<Delivery>> getDeliveryHistory(String userId);
  Future<List<DeliveryStatusUpdate>> checkForStatusUpdates(String userId);
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,String delivery_id, String paymentMethod);
  Future<PaymentInfoModel> getPaymentInfo(String deliveryId);
}

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource remoteDataSource;

  DeliveryRepositoryImpl(this.remoteDataSource);

  @override
  Future<Delivery> createDeliveryRequest(Delivery delivery) {
    return remoteDataSource.createDeliveryRequest(delivery);
  }

  @override
  Future<String> uploadImage(String imagePath, {String type = 'proof'}) {
    return remoteDataSource.uploadImage(imagePath, type: type);
  }

  @override
  Future<List<Delivery>> getDeliveryHistory(String userId) {
    return remoteDataSource.getDeliveryHistory(userId);
  }

  @override
  Future<List<DeliveryStatusUpdate>> checkForStatusUpdates(String userId) {
    return remoteDataSource.checkForStatusUpdates(userId);
  }
  @override
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,String delivery_id,String paymentMethod) {
    return remoteDataSource.payForDelivery(customer,phoneNumber, amount,delivery_id, paymentMethod);
  }
  @override
  Future<PaymentInfoModel> getPaymentInfo(String deliveryId) {
    return remoteDataSource.getPaymentInfo(deliveryId);
  }
}
