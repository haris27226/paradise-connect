import 'package:dartz/dartz.dart';
import '../../entities/activity/activity.dart';
import '../../repositories/contact_repository.dart';

class GetActivitiesUseCase {
  final ContactRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<Either<String, List<Activity>>> call({
    required int contactId,
    int? dealId,
    String? activityType,
    int page = 1,
  }) async {
    return await repository.getActivities(
      contactId: contactId,
      dealId: dealId,
      activityType: activityType,
      page: page,
    );
  }
}
