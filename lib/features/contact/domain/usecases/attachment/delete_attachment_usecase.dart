import '../../repositories/contact_repository.dart';

class DeleteAttachmentUseCase {
  final ContactRepository repository;

  DeleteAttachmentUseCase(this.repository);

  Future<void> call({required int contactId,required int attachmentId,}) {
    return repository.deleteAttachment(contactId: contactId,attachmentId: attachmentId,);
  }
}