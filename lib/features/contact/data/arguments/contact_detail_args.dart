import 'package:progress_group/features/contact/domain/entities/attachment/attachment_entity.dart';
import 'package:progress_group/features/contact/domain/entities/contact/contact.dart';

class ContactDetailArgs {
  final ContactAttachment? dataAttachment;
  final Contact? dataContact;
  final int page;
  final String? namePage;

  ContactDetailArgs({
    this.dataAttachment,
    this.dataContact,
    this.page = 0, // 0: create 1: edit
    this.namePage,
  });
}