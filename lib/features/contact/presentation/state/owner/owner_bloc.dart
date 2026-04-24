import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/get_owners_usecase.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final GetOwnersUseCase getOwnersUseCase;

  OwnerBloc({required this.getOwnersUseCase}) : super(const OwnerState()) {
    on<FetchOwnersEvent>(_onFetchOwners);
    on<SearchOwnersEvent>(
      _onSearchOwners,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onFetchOwners(
    FetchOwnersEvent event,
    Emitter<OwnerState> emit,
  ) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    if (!event.isLoadMore) {
      emit(state.copyWith(
        status: OwnerStatus.loading,
        owners: [],
        currentPage: 1,
        hasReachedMax: false,
      ));
    }

    final result = await getOwnersUseCase(
      search: state.search,
      page: event.isLoadMore ? state.currentPage + 1 : 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerStatus.error,
        errorMessage: failure,
      )),
      (newOwners) {
        if (newOwners.isEmpty) {
          emit(state.copyWith(
            status: OwnerStatus.loaded,
            hasReachedMax: true,
          ));
        } else {
          emit(state.copyWith(
            status: OwnerStatus.loaded,
            owners: event.isLoadMore
                ? [...state.owners, ...newOwners]
                : newOwners,
            currentPage: event.isLoadMore ? state.currentPage + 1 : 1,
            hasReachedMax: newOwners.length < 10,
          ));
        }
      },
    );
  }

  Future<void> _onSearchOwners(
    SearchOwnersEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(state.copyWith(search: event.query));
    add(const FetchOwnersEvent(isLoadMore: false));
  }
}
