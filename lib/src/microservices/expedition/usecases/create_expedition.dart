
import '../data/expedition/create_expedition_model.dart';
import '../domain/expedition/repo.dart';

class CreateExpeditionUseCase {
  final ExpeditionRepository repository;

  CreateExpeditionUseCase(this.repository);

  Future<CreateExpedition> call({
    required Map<String, dynamic> body,
    required String customerToken,
  }) {
    return repository.createAnExpedition(
      body: body,
      customerToken: customerToken,
    );
  }
}