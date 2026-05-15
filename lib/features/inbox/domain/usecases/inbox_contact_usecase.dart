import '../entities/inbox_contact_entity.dart';
import '../repositories/inbox_contact_repository.dart';

class GetInboxContactsUsecase {
  final InboxContactRepository repository;

  GetInboxContactsUsecase(this.repository);

  Future<(List<InboxContact>, List<InboxContact>)> call({
    String? search,
    int? cPage,
    int? gPage,
    List<int>? salesExecutiveIds,
    int? statusProspectId,
    String? startDate,
    String? endDate,
  }) {
    return repository.getContacts(
      search: search,
      cPage: cPage,
      gPage: gPage,
      salesExecutiveIds: salesExecutiveIds,
      statusProspectId: statusProspectId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}