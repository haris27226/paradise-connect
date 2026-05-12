import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/contact/domain/usecases/lost_reason/get_lost_reason.dart';
import 'lost_reason_event.dart';
import 'lost_reason_state.dart';

class LostReasonBloc extends Bloc<LostReasonEvent, LostReasonState> {
  final GetLostReasonsUseCase getLostReasonsUseCase;

  LostReasonBloc({
    required this.getLostReasonsUseCase,
  }) : super(const LostReasonState()) {
    on<FetchLostReasonsEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchLostReasonsEvent event,
    Emitter<LostReasonState> emit,
  ) async {
    emit(state.copyWith(status: LostReasonStatus.loading));

    final result = await getLostReasonsUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LostReasonStatus.error,
          errorMessage: failure,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: LostReasonStatus.loaded,
          reasons: data,
        ),
      ),
    );
  }
}