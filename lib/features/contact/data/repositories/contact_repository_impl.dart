import 'package:dartz/dartz.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_response.dart';
import '../../domain/entities/create_activity_params.dart';
import '../../domain/entities/owner.dart';
import '../../domain/entities/prospect_status.dart';
import '../../domain/entities/sales_executive.dart';
import '../../domain/entities/sales_manager.dart';
import '../../domain/entities/create_contact_params.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_remote_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, ContactResponse>> getContacts({int page = 1, int perPage = 10, String? search, String? startDate, String? endDate, int? ownerId, int? statusProspectId}) async {
    try {
      final result = await remoteDataSource.getContacts(
        page: page,
        perPage: perPage,
        search: search,
        startDate: startDate,
        endDate: endDate,
        ownerId: ownerId,
        statusProspectId: statusProspectId,
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
  Future<Either<String, List<Owner>>> getOwners({String? search, int? page}) async {
    try {
      final owners = await remoteDataSource.getOwners(
        search: search ?? '',
        page: page ?? 1,
      );
      return Right(owners);
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
  Future<Either<String, List<SalesExecutive>>> getSalesExecutives({String? search, int? page}) async {
    try {
      final salesExecutives = await remoteDataSource.getSalesExecutives(
        search: search ?? '',
        page: page ?? 1,
      );
      return Right(salesExecutives);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SalesManager>>> getSalesManagers({String? search, int? page}) async {
    try {
      final salesManagers = await remoteDataSource.getSalesManagers(
        search: search ?? '',
        page: page ?? 1,
      );
      return Right(salesManagers);
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
  Future<Either<String, List<Activity>>> getActivities({required int contactId, int? dealId, String? activityType, int page = 1}) async {
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
  Future<Either<String, void>> createActivity(CreateActivityParams params) async {
    try {
      await remoteDataSource.createActivity(params);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
