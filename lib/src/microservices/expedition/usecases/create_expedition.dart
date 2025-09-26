
import '../../../models/CustomerModel.dart';
import '../data/expedition/create_expedition_model.dart';
import '../data/expedition/expedition_model.dart';
import '../domain/expedition/repo.dart';

class CreateExpeditionUseCase {
  final ExpeditionRepository repository;
  CreateExpeditionUseCase(this.repository);
  Future<ExpeditionModel> call({
    required CreateExpedition body,
    required CustomerModel customer,
  }) {
    return repository.createAnExpedition(
      expedition:(body),
      customer: customer,
    );
  }
}