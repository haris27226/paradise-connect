import '../../../domain/entities/attachment/upload_attachment_params.dart';

abstract class UploadAttachmentEvent {}

class SubmitUploadAttachmentEvent extends UploadAttachmentEvent {
  final UploadAttachmentParams params;

  SubmitUploadAttachmentEvent(this.params);
}


class SubmitAttachmentEvent extends UploadAttachmentEvent {
  final UploadAttachmentParams params;
  final int? attachmentId; // null = create

  SubmitAttachmentEvent({
    required this.params,
    this.attachmentId,
  });
}