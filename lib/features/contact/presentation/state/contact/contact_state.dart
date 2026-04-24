import 'package:equatable/equatable.dart';
import 'package:progress_group/features/contact/domain/entities/contact.dart';


enum ContactStatus { initial, loading, loaded, error, creating, createSuccess, loadingDetail, detailLoaded }

class ContactState extends Equatable {
  final ContactStatus status;
  final List<Contact> contacts;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String? search;
  final String? startDate;
  final String? endDate;
  final int? ownerId;
  final int? statusProspectId;
  final Contact? contactDetail;

  const ContactState({
    this.status = ContactStatus.initial,
    this.contacts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.search,
    this.startDate,
    this.endDate,
    this.ownerId,
    this.statusProspectId,
    this.contactDetail,
  });

  ContactState copyWith({
    ContactStatus? status,
    List<Contact>? contacts,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? search,
    String? startDate,
    String? endDate,
    int? ownerId,
    int? statusProspectId,
    bool clearSearch = false,
    bool clearDates = false,
    bool clearOwner = false,
    bool clearStatus = false,
    Contact? contactDetail,
  }) {
    return ContactState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: clearSearch ? null : (search ?? this.search),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      ownerId: clearOwner ? null : (ownerId ?? this.ownerId),
      statusProspectId: clearStatus ? null : (statusProspectId ?? this.statusProspectId),
      contactDetail: contactDetail ?? this.contactDetail,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contacts,
        errorMessage,
        currentPage,
        hasReachedMax,
        search,
        startDate,
        endDate,
        ownerId,
        statusProspectId,
        contactDetail,
      ];
}
