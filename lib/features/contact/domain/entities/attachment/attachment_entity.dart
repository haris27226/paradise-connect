class ContactAttachment {
  final int contactAttachmentId;
  final int contactId;
  final int? dealId;
  final int? activityId;
  final int attachmentTypeId;
  final String attachmentUrl;
  final String attachmentTypeName;
  final String attachmentNote;
  final DateTime createDatetime;

  ContactAttachment({
    required this.contactAttachmentId,
    required this.contactId,
    this.dealId,
    this.activityId,
    required this.attachmentTypeId,
    required this.attachmentUrl,
    required this.attachmentTypeName,
    required this.attachmentNote,
    required this.createDatetime,
  });
}