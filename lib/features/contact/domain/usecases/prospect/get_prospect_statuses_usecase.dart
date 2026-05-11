import 'package:dartz/dartz.dart';
import '../../entities/prospect/prospect_status.dart';
import '../../repositories/contact_repository.dart';

class GetProspectStatusesUseCase {
  final ContactRepository repository;

  GetProspectStatusesUseCase(this.repository);

  Future<Either<String, List<ProspectStatusEntity>>> call({String? type}) async {
    return await repository.getProspectStatuses(type: type);
  }
}
