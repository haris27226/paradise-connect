import 'package:dartz/dartz.dart';
import 'package:progress_group/features/contact/domain/entities/activity/create_activity_visit_params.dart';
import 'package:progress_group/features/contact/domain/repositories/contact_repository.dart';

class CreateActivityVisitUseCase {
  final ContactRepository repository;

  CreateActivityVisitUseCase(this.repository);

  Future<Either<String, void>> call(CreateVisitParams params) {
    return repository.createActivityVisit(params);
  }
}