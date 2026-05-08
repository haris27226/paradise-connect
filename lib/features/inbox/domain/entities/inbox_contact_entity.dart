class InboxContact {
  final int id;
  final int? crmContactId;
  final String name;
  final String? photo;
  final String jid;
  final bool isGroup;
  final String initials;
  final String? lastConversationDate;
  final String? ownerName;
  final String sessionCode;
  final int unreadCount;
  final String? crmContactName;
  final String? lastMessageReceiver;
  final String? lastMessageSender;

  InboxContact({
    required this.id,
    this.crmContactId,
    required this.name,
    this.photo,
    required this.jid,
    required this.isGroup,
    required this.initials,
    this.lastConversationDate,
    this.ownerName,
    required this.sessionCode,
    this.unreadCount = 0,
    this.crmContactName,
    this.lastMessageReceiver,
    this.lastMessageSender,
  });
}