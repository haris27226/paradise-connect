import 'package:equatable/equatable.dart';
import '../../../domain/entities/create_contact_params.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

class FetchContactsEvent extends ContactEvent {
  final int page;
  final int perPage;
  final String? search;
  final String? startDate;
  final String? endDate;
  final int? ownerId;
  final int? statusProspectId;
  final bool isRefresh;

  const FetchContactsEvent({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.startDate,
    this.endDate,
    this.ownerId,
    this.statusProspectId,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, perPage, search, startDate, endDate, ownerId, statusProspectId, isRefresh];
}

class CreateContactEvent extends ContactEvent {
  final CreateContactParams params;

  const CreateContactEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class FetchContactDetailEvent extends ContactEvent {
  final int contactId;

  const FetchContactDetailEvent(this.contactId);

  @override
  List<Object?> get props => [contactId];
}
