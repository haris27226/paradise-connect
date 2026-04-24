import 'package:dartz/dartz.dart';
import '../entities/create_contact_params.dart';
import '../repositories/contact_repository.dart';

class CreateContactUseCase {
  final ContactRepository repository;

  CreateContactUseCase(this.repository);

  Future<Either<String, void>> call(CreateContactParams params) async {
    return await repository.createContact(params);
  }
}
