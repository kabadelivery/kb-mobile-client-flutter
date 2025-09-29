import '../data/expedition/line_model.dart';
import '../domain/expedition/repo.dart';

class GetShippingLines {
  final ExpeditionRepository repository;
  GetShippingLines(this.repository);
  Future<List<LineModel>> call({required String customerToken}) {
    return repository.getShippingLines(customerToken: customerToken);
  }
}