import 'package:equatable/equatable.dart';

class WhatsappUnreadSummaryEntity extends Equatable {
  final String jid;
  final String sessionId;
  final String contactName;
  final String? photoProfile;
  final int? contactId;
  final bool hasContact;
  final int unreadCount;
  final String lastMessageAt;

  const WhatsappUnreadSummaryEntity({
    required this.jid,
    required this.sessionId,
    required this.contactName,
    this.photoProfile,
    this.contactId,
    required this.hasContact,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  @override
  List<Object?> get props => [
        jid,
        sessionId,
        contactName,
        photoProfile,
        contactId,
        hasContact,
        unreadCount,
        lastMessageAt,
      ];
}