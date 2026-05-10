import 'package:progress_group/features/contact/domain/entities/activity/whatsapp_activity_entity.dart';

class WhatsappUnreadSummaryModel {
  final String jid;
  final String sessionId;
  final String contactName;
  final String? photoProfile;
  final int? contactId;
  final bool hasContact;
  final int unreadCount;
  final String lastMessageAt;

  WhatsappUnreadSummaryModel({
    required this.jid,
    required this.sessionId,
    required this.contactName,
    this.photoProfile,
    this.contactId,
    required this.hasContact,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  factory WhatsappUnreadSummaryModel.fromJson(Map<String, dynamic> json) {
    return WhatsappUnreadSummaryModel(
      jid: json['jid'],
      sessionId: json['session_id'],
      contactName: json['contact_name'],
      photoProfile: json['photo_profile'],
      contactId: json['contact_id'],
      hasContact: json['has_contact'],
      unreadCount: json['unread_count'],
      lastMessageAt: json['last_message_at'],
    );
  }

  WhatsappUnreadSummaryEntity toEntity() {
    return WhatsappUnreadSummaryEntity(
      jid: jid,
      sessionId: sessionId,
      contactName: contactName,
      photoProfile: photoProfile,
      contactId: contactId,
      hasContact: hasContact,
      unreadCount: unreadCount,
      lastMessageAt: lastMessageAt,
    );
  }
}