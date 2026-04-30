import 'package:dartz/dartz.dart';
import '../../entities/attachment/upload_attachment_params.dart';
import '../../repositories/contact_repository.dart';

class UploadAttachmentUseCase {
  final ContactRepository repository;

  UploadAttachmentUseCase(this.repository);

  Future<Either<String, void>> call(UploadAttachmentParams params) async {
    return await repository.uploadAttachment(params);
  }
}
