abstract class InboxContactEvent {}

class GetInboxContactsEvent extends InboxContactEvent {
  final String? search;
  final int? cPage;
  final int? gPage;
  final bool isLoadMore;

  GetInboxContactsEvent({this.search, this.cPage, this.gPage, this.isLoadMore = false});
}