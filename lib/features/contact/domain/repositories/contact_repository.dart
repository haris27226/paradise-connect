import 'package:dartz/dartz.dart';
import '../entities/activity.dart';
import '../entities/contact.dart';
import '../entities/contact_response.dart';
import '../entities/create_activity_params.dart';
import '../entities/prospect_status.dart';
import '../entities/create_contact_params.dart';

abstract class ContactRepository {
  Future<Either<String, ContactResponse>> getContacts({  int page = 1,  int perPage = 10,  String? search,  String? startDate,  String? endDate,  List<int>? ownerIds,  List<int>? statusProspectIds,});
  Future<Either<String, Contact>> getContactDetail(int id);
  Future<Either<String, List<ProspectStatus>>> getProspectStatuses();
  Future<Either<String, void>> createContact(CreateContactParams params);
  Future<Either<String, List<Activity>>> getActivities({required int contactId, int? dealId, String? activityType, int page = 1,});
  Future<Either<String, void>> createActivity(CreateActivityParams params);
}
