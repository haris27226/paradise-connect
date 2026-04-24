import 'package:dartz/dartz.dart';
import '../entities/owner.dart';
import '../repositories/contact_repository.dart';

class GetOwnersUseCase {
  final ContactRepository repository;

  GetOwnersUseCase(this.repository);

  Future<Either<String, List<Owner>>> call({String search = '', int page = 1}) async {
    return await repository.getOwners(search: search, page: page);
  }
}
