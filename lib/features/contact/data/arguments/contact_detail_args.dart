import 'package:progress_group/features/contact/domain/entities/activity/activity_entity.dart';
import 'package:progress_group/features/contact/domain/entities/attachment/attachment_entity.dart';
import 'package:progress_group/features/contact/domain/entities/contact/contact.dart';

class ContactDetailArgs {
  final ContactAttachment? dataAttachment;
  final Contact? dataContact;
  final ActivityEntity? dataActivity;
  final int page;
  final String? namePage;
  final int initialTab;

  ContactDetailArgs({
    this.dataAttachment,
    this.dataContact,
    this.dataActivity,
    this.page = 0, // 0: create 1: edit
    this.namePage,
    this.initialTab = 0,
  });
}