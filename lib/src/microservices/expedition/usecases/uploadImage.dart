import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';

class UploadExpeditionImage{
  ExpeditionRepository repo;
  UploadExpeditionImage({required this.repo});

  Future<String> call({required String imagePath}){
    return repo.uploadImage(imagePath);
  }
}