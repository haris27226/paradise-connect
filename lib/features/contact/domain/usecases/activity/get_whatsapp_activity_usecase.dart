import 'package:dartz/dartz.dart';
import 'package:progress_group/features/contact/domain/entities/activity/whatsapp_activity_entity.dart';

import '../../repositories/contact_repository.dart';

class GetWhatsappUnreadSummaryUseCase {
  final ContactRepository repository;

  GetWhatsappUnreadSummaryUseCase(this.repository);

  Future<Either<String, List<WhatsappUnreadSummaryEntity>>> call(int contactId) async {
    return await repository.getWhatsappUnreadSummary(contactId);
  }
}