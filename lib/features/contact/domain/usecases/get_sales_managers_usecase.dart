import 'package:dartz/dartz.dart';
import '../entities/sales_manager.dart';
import '../repositories/contact_repository.dart';

class GetSalesManagersUseCase {
  final ContactRepository repository;

  GetSalesManagersUseCase(this.repository);

  Future<Either<String, List<SalesManager>>> call({String search = '', int page = 1}) async {
    return await repository.getSalesManagers(search: search, page: page);
  }
}
