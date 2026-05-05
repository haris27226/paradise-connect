abstract class InboxContactEvent {}

class GetInboxContactsEvent extends InboxContactEvent {
  final String? search;
  final int? cPage;
  final int? gPage;
  final int? salesExecutiveId;
  final int? statusProspectId;
  final String? startDate;
  final String? endDate;
  final bool isLoadMore;

  GetInboxContactsEvent({
    this.search,
    this.cPage,
    this.gPage,
    this.salesExecutiveId,
    this.statusProspectId,
    this.startDate,
    this.endDate,
    this.isLoadMore = false,
  });
}