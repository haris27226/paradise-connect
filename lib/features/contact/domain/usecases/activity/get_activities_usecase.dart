import 'package:dartz/dartz.dart';
import '../../entities/activity/activity_entity.dart';
import '../../repositories/contact_repository.dart';

class GetActivitiesUseCase {
  final ContactRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<Either<String, List<ActivityEntity>>> call({
    int? contactId,
    int? dealId,
    String? activityType,
    String? followUpStartDate,
    String? followUpEndDate,
    int page = 1,
  }) async {
    return await repository.getActivities(
      contactId: contactId,
      dealId: dealId,
      activityType: activityType,
      followUpStartDate: followUpStartDate,
      followUpEndDate: followUpEndDate,
      page: page,
    );
  }
}
