import 'package:dartz/dartz.dart';
import '../entities/sales_executive.dart';
import '../repositories/contact_repository.dart';

class GetSalesExecutivesUseCase {
  final ContactRepository repository;

  GetSalesExecutivesUseCase(this.repository);

  Future<Either<String, List<SalesExecutive>>> call({String search = '', int page = 1}) async {
    return await repository.getSalesExecutives(search: search, page: page);
  }
}
