
import 'package:progress_group/features/contact/domain/entities/attachment/attachment_entity.dart';

abstract class AttachmentState {}

class AttachmentInitial extends AttachmentState {}

class AttachmentLoading extends AttachmentState {}

class AttachmentLoaded extends AttachmentState {
  final List<ContactAttachment> data;

  AttachmentLoaded(this.data);
}

class AttachmentError extends AttachmentState {
  final String message;

  AttachmentError(this.message);
}