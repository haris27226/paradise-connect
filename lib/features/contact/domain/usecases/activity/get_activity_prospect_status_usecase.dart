import 'package:dartz/dartz.dart';
import 'package:progress_group/features/contact/domain/entities/activity/activity_prospect_status.dart';
import 'package:progress_group/features/contact/domain/repositories/contact_repository.dart';

class GetActivityProspectStatusUseCase {
  final ContactRepository repository;

  GetActivityProspectStatusUseCase(this.repository);

  Future<Either<String, List<ActivityProspectStatusEntity>>> call(int contactId) {
    return repository.getActivityProspectStatus(contactId);
  }
}