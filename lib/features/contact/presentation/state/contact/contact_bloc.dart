import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_contacts_usecase.dart';
import '../../../domain/usecases/create_contact_usecase.dart';
import '../../../domain/usecases/get_contact_detail_usecase.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetContactsUseCase getContactsUseCase;
  final CreateContactUseCase createContactUseCase;
  final GetContactDetailUseCase getContactDetailUseCase;

  ContactBloc({
    required this.getContactsUseCase,
    required this.createContactUseCase,
    required this.getContactDetailUseCase,
  }) : super(const ContactState()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<CreateContactEvent>(_onCreateContact);
    on<FetchContactDetailEvent>(_onFetchContactDetail);
  }

  Future<void> _onFetchContacts(  FetchContactsEvent event,  Emitter<ContactState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: ContactStatus.loading,
        currentPage: 1,
        hasReachedMax: false,
        contacts: [],
        search: event.search,
        startDate: event.startDate,
        endDate: event.endDate,
        ownerId: event.ownerId,
        statusProspectId: event.statusProspectId,
        clearSearch: event.search == null && state.search != null,
        clearDates: (event.startDate == null || event.endDate == null) && (state.startDate != null || state.endDate != null),
        clearOwner: event.ownerId == null && state.ownerId != null,
        clearStatus: event.statusProspectId == null && state.statusProspectId != null,
      ));
    } else {
      if (state.hasReachedMax && state.status == ContactStatus.loaded) return;
      if (state.status == ContactStatus.initial) {
        emit(state.copyWith(
          status: ContactStatus.loading,
          search: event.search,
          startDate: event.startDate,
          endDate: event.endDate,
          ownerId: event.ownerId,
          statusProspectId: event.statusProspectId,
        ));
      }
    }

    final currentPage = event.isRefresh ? 1 : state.currentPage;

    final result = await getContactsUseCase(
      page: currentPage,
      perPage: event.perPage,
      search: event.search ?? state.search,
      startDate: event.startDate ?? state.startDate,
      endDate: event.endDate ?? state.endDate,
      ownerId: event.ownerId ?? state.ownerId,
      statusProspectId: event.statusProspectId ?? state.statusProspectId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactStatus.error,
        errorMessage: failure,
      )),
      (response) {
        final isLastPage = response.nextPageUrl == null;
        emit(state.copyWith(
          status: ContactStatus.loaded,
          contacts: event.isRefresh
              ? response.data
              : [...state.contacts, ...response.data],
          hasReachedMax: isLastPage,
          currentPage: currentPage + 1,
        ));
      },
    );
  }

  Future<void> _onCreateContact(
    CreateContactEvent event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(status: ContactStatus.creating));

    final result = await createContactUseCase(event.params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactStatus.error,
        errorMessage: failure,
      )),
      (_) => emit(state.copyWith(status: ContactStatus.createSuccess)),
    );
  }

  Future<void> _onFetchContactDetail(
    FetchContactDetailEvent event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(status: ContactStatus.loadingDetail));

    final result = await getContactDetailUseCase(event.contactId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ContactStatus.error,
        errorMessage: failure,
      )),
      (contact) => emit(state.copyWith(
        status: ContactStatus.detailLoaded,
        contactDetail: contact,
      )),
    );
  }
}
