import 'package:dartz/dartz.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_response.dart';
import '../../domain/entities/create_activity_params.dart';
import '../../domain/entities/prospect_status.dart';
import '../../domain/entities/create_contact_params.dart';
import '../../domain/entities/contact_property.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, ContactResponse>> getContacts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? startDate,
    String? endDate,
    List<int>? ownerIds,
    List<int>? statusProspectIds,
  }) async {
    try {
      final result = await remoteDataSource.getContacts(
        page: page,
        perPage: perPage,
        search: search,
        startDate: startDate,
        endDate: endDate,
        ownerIds: ownerIds,
        statusProspectIds: statusProspectIds,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Contact>> getContactDetail(int id) async {
    try {
      final result = await remoteDataSource.getContactDetail(id);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ProspectStatus>>> getProspectStatuses() async {
    try {
      final result = await remoteDataSource.getProspectStatuses();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ContactPropertyGroup>>>
  getContactProperties() async {
    try {
      final result = await remoteDataSource.getContactProperties();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createContact(CreateContactParams params) async {
    try {
      await remoteDataSource.createContact(params);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateContact(
    int id,
    CreateContactParams params,
  ) async {
    try {
      await remoteDataSource.updateContact(id, params);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Activity>>> getActivities({
    required int contactId,
    int? dealId,
    String? activityType,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.getActivities(
        contactId: contactId,
        dealId: dealId,
        activityType: activityType,
        page: page,
      );
      return Right(result.activities);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createActivity(
    CreateActivityParams params,
  ) async {
    try {
      await remoteDataSource.createActivity(params);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
