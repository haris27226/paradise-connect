import 'package:progress_group/features/contact/domain/entities/contact.dart';

class ContactDetailArgs {
  final Contact? data;
  final int page;

  ContactDetailArgs({
    this.data,
    this.page = 0, // 0: create 1: edit
  });
}