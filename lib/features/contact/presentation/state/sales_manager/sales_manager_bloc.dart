import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/get_sales_managers_usecase.dart';
import 'sales_manager_event.dart';
import 'sales_manager_state.dart';

class SalesManagerBloc extends Bloc<SalesManagerEvent, SalesManagerState> {
  final GetSalesManagersUseCase getSalesManagersUseCase;

  SalesManagerBloc({required this.getSalesManagersUseCase})
      : super(const SalesManagerState()) {
    on<FetchSalesManagersEvent>(_onFetchSalesManagers);
    on<SearchSalesManagersEvent>(
      _onSearchSalesManagers,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onFetchSalesManagers(
    FetchSalesManagersEvent event,
    Emitter<SalesManagerState> emit,
  ) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    if (!event.isLoadMore) {
      emit(state.copyWith(
        status: SalesManagerStatus.loading,
        salesManagers: [],
        currentPage: 1,
        hasReachedMax: false,
      ));
    }

    final result = await getSalesManagersUseCase(
      search: state.search,
      page: event.isLoadMore ? state.currentPage + 1 : 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SalesManagerStatus.error,
        errorMessage: failure,
      )),
      (newManagers) {
        if (newManagers.isEmpty) {
          emit(state.copyWith(
            status: SalesManagerStatus.loaded,
            hasReachedMax: true,
          ));
        } else {
          emit(state.copyWith(
            status: SalesManagerStatus.loaded,
            salesManagers: event.isLoadMore
                ? [...state.salesManagers, ...newManagers]
                : newManagers,
            currentPage: event.isLoadMore ? state.currentPage + 1 : 1,
            hasReachedMax: newManagers.length < 10,
          ));
        }
      },
    );
  }

  Future<void> _onSearchSalesManagers(
    SearchSalesManagersEvent event,
    Emitter<SalesManagerState> emit,
  ) async {
    emit(state.copyWith(search: event.query));
    add(const FetchSalesManagersEvent(isLoadMore: false));
  }
}
