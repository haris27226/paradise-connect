import 'package:dartz/dartz.dart';
import '../entities/create_activity_params.dart';
import '../repositories/contact_repository.dart';

class CreateActivityUseCase {
  final ContactRepository repository;

  CreateActivityUseCase(this.repository);

  Future<Either<String, void>> call(CreateActivityParams params) async {
    return await repository.createActivity(params);
  }
}
