import '../data/expedition/expedition_model.dart';
import '../domain/expedition/repo.dart';

class GetUserExpedition {
  final ExpeditionRepository repository;

  GetUserExpedition(this.repository);

  Future<List<ExpeditionModel>> call({
    required String customerToken,
  }) {
    return repository.getUserExpedition(
      customerToken: customerToken,
    );
  }
}