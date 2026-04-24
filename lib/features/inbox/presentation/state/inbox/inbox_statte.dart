import '../../../domain/entities/inbox_contact_entity.dart';

abstract class InboxContactState {}

class InboxContactInitial extends InboxContactState {}

class InboxContactLoading extends InboxContactState {}

class InboxContactLoaded extends InboxContactState {
  final List<InboxContact> contacts;
  final List<InboxContact> groups;
  final bool isFetchingMore;

  InboxContactLoaded(this.contacts, this.groups, {this.isFetchingMore = false});
}

class InboxContactError extends InboxContactState {
  final String message;

  InboxContactError(this.message);
}