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
  final List<int>? ownerIds;
  final List<int>? statusProspectIds;
  final bool isRefresh;
  final bool clearSearch;
  final bool clearDates;
  final bool clearOwner;
  final bool clearStatus;

  const FetchContactsEvent({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.startDate,
    this.endDate,
    this.ownerIds,
    this.statusProspectIds,
    this.isRefresh = false,
    this.clearSearch = false,
    this.clearDates = false,
    this.clearOwner = false,
    this.clearStatus = false,
  });

  @override
  List<Object?> get props => [
    page,
    perPage,
    search,
    startDate,
    endDate,
    ownerIds,
    statusProspectIds,
    isRefresh,
    clearSearch,
    clearDates,
    clearOwner,
    clearStatus,
  ];
}

class CreateContactEvent extends ContactEvent {
  final CreateContactParams params;

  const CreateContactEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdateContactEvent extends ContactEvent {
  final int contactId;
  final CreateContactParams params;

  const UpdateContactEvent(this.contactId, this.params);

  @override
  List<Object?> get props => [contactId, params];
}

class FetchContactDetailEvent extends ContactEvent {
  final int contactId;

  const FetchContactDetailEvent(this.contactId);

  @override
  List<Object?> get props => [contactId];
}
