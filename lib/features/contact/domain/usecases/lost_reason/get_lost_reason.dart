import 'package:dartz/dartz.dart';
import 'package:progress_group/features/contact/domain/entities/lost_reason/lost_reason_entity.dart';
import 'package:progress_group/features/contact/domain/repositories/contact_repository.dart';

class GetLostReasonsUseCase {
  final ContactRepository repository;

  GetLostReasonsUseCase(this.repository);

  Future<Either<String, List<LostReasonEntity>>> call() async {
    return await repository.getLostReasons();
  }
}