import 'package:dartz/dartz.dart';
import '../entities/contact_response.dart';
import '../repositories/contact_repository.dart';

class GetContactsUseCase {
  final ContactRepository repository;

  GetContactsUseCase(this.repository);

  Future<Either<String, ContactResponse>> call({  int page = 1,  int perPage = 10,  String? search,  String? startDate,  String? endDate,  int? ownerId,  int? statusProspectId,}) {
    return repository.getContacts(
      page: page,
      perPage: perPage,
      search: search,
      startDate: startDate,
      endDate: endDate,
      ownerId: ownerId,
      statusProspectId: statusProspectId,
    );
  }
}
