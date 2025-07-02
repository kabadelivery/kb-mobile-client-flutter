import '../../domain/order/repository.dart';

class UploadImage {
  final DeliveryRepository repository;

  UploadImage(this.repository);

  Future<String> call({required String imagePath, String type = 'proof'}) {
    return repository.uploadImage(imagePath, type: type);
  }
}
