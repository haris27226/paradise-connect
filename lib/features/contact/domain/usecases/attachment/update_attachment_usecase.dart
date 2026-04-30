import 'package:dartz/dartz.dart';
import 'package:progress_group/features/contact/domain/entities/attachment/upload_attachment_params.dart';
import 'package:progress_group/features/contact/domain/repositories/contact_repository.dart';

class UpdateAttachmentUseCase {
  final ContactRepository repository;

  UpdateAttachmentUseCase(this.repository);

  Future<Either<String, void>> call({  required int contactId,  required int attachmentId,  required UploadAttachmentParams params,}) {
    return repository.updateAttachment(
      contactId: contactId,
      attachmentId: attachmentId,
      params: params,
    );
  }
}