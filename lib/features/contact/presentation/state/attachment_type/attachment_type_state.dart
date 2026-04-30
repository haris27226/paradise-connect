import '../../../domain/entities/attachment/attachment_type.dart';

abstract class AttachmentTypeState {}

class AttachmentTypeInitial extends AttachmentTypeState {}

class AttachmentTypeLoading extends AttachmentTypeState {}

class AttachmentTypeLoaded extends AttachmentTypeState {
  final List<AttachmentType> data;

  AttachmentTypeLoaded(this.data);
}

class AttachmentTypeError extends AttachmentTypeState {
  final String message;

  AttachmentTypeError(this.message);
}
