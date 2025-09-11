import '../data/expedition/negociation_model.dart';
import '../domain/expedition/repo.dart';

class CreateNegociation {
  final ExpeditionRepository repository;

  CreateNegociation(this.repository);

  Future<NegotiationModel> call({
    required Map<String, dynamic> body,
    required String customerToken,
  }) {
    return repository.createNegociation(
      body: body,
      customerToken: customerToken,
    );
  }
}