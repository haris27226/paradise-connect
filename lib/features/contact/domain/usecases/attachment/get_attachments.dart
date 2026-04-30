import 'package:dartz/dartz.dart';

import '../../entities/attachment/attachment_entity.dart';
import '../../repositories/contact_repository.dart';

class GetAttachments {
  final ContactRepository repository;

  GetAttachments(this.repository);

  Future<Either<String, List<ContactAttachment>>> call({required int contactId,int? dealId,}) {
    return repository.getAttachments(contactId: contactId,dealId: dealId);
  }
}