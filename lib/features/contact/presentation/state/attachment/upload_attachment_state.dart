abstract class UploadAttachmentState {}

class UploadAttachmentInitial extends UploadAttachmentState {}

class UploadAttachmentLoading extends UploadAttachmentState {}

class UploadAttachmentSuccess extends UploadAttachmentState {}

class UploadAttachmentError extends UploadAttachmentState {
  final String message;

  UploadAttachmentError(this.message);
}
