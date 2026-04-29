import 'package:dartz/dartz.dart';
import '../repositories/contact_repository.dart';

class DeleteContactUseCase {
  final ContactRepository repository;
  DeleteContactUseCase(this.repository);

  Future<Either<String, void>> call(int id) async {
    return await repository.deleteContact(id);
  }
}
