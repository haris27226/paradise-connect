import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/get_sales_executives_usecase.dart';
import 'sales_executive_event.dart';
import 'sales_executive_state.dart';

class SalesExecutiveBloc extends Bloc<SalesExecutiveEvent, SalesExecutiveState> {
  final GetSalesExecutivesUseCase getSalesExecutivesUseCase;

  SalesExecutiveBloc({required this.getSalesExecutivesUseCase}): super(const SalesExecutiveState()) {
    on<FetchSalesExecutivesEvent>(_onFetchSalesExecutives);
    on<SearchSalesExecutivesEvent>(
      _onSearchSalesExecutives,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onFetchSalesExecutives(
    FetchSalesExecutivesEvent event,
    Emitter<SalesExecutiveState> emit,
  ) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    if (!event.isLoadMore) {
      emit(state.copyWith(
        status: SalesExecutiveStatus.loading,
        salesExecutives: [],
        currentPage: 1,
        hasReachedMax: false,
      ));
    }

    final result = await getSalesExecutivesUseCase(
      search: state.search,
      page: event.isLoadMore ? state.currentPage + 1 : 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SalesExecutiveStatus.error,
        errorMessage: failure,
      )),
      (newExecutives) {
        if (newExecutives.isEmpty) {
          emit(state.copyWith(
            status: SalesExecutiveStatus.loaded,
            hasReachedMax: true,
          ));
        } else {
          emit(state.copyWith(
            status: SalesExecutiveStatus.loaded,
            salesExecutives: event.isLoadMore
                ? [...state.salesExecutives, ...newExecutives]
                : newExecutives,
            currentPage: event.isLoadMore ? state.currentPage + 1 : 1,
            hasReachedMax: newExecutives.length < 10,
          ));
        }
      },
    );
  }

  Future<void> _onSearchSalesExecutives(
    SearchSalesExecutivesEvent event,
    Emitter<SalesExecutiveState> emit,
  ) async {
    emit(state.copyWith(search: event.query));
    add(const FetchSalesExecutivesEvent(isLoadMore: false));
  }
}
