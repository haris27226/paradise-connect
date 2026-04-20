abstract class MessageEvent {}

class GetChatHistoryEvent extends MessageEvent {
  final String sessionId;
  final String jid;

  GetChatHistoryEvent({required this.sessionId, required this.jid});
}