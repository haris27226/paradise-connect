abstract class MessageEvent {}

class GetChatHistoryEvent extends MessageEvent {
  final String sessionId;
  final String jid;
  final int page;
  final bool isLoadMore;

  GetChatHistoryEvent({
    required this.sessionId, 
    required this.jid, 
    this.page = 1, 
    this.isLoadMore = false
  });
}