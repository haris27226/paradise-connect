import 'package:dartz/dartz.dart'; // Jika kamu pakai dartz untuk Either
import '../../entities/attachment/attachment_type.dart';
import '../../repositories/contact_repository.dart';

class GetAttachmentTypesUseCase {
  final ContactRepository repository;

  GetAttachmentTypesUseCase(this.repository);

  /// Callable class: memungkinkan kamu memanggil use case 
  /// seperti fungsi: getAttachmentTypesUseCase()
  Future<Either<String, List<AttachmentType>>> call() async {
    return await repository.getAttachmentTypes();
  }
}