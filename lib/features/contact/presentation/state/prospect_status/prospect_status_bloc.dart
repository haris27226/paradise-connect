import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/prospect/get_prospect_statuses_usecase.dart';
import 'prospect_status_event.dart';
import 'prospect_status_state.dart';

class ProspectStatusBloc extends Bloc<ProspectStatusEvent, ProspectStatusState> {
  final GetProspectStatusesUseCase getProspectStatusesUseCase;

  ProspectStatusBloc({required this.getProspectStatusesUseCase}) : super(const ProspectStatusState()) {
    on<FetchProspectStatusesEvent>(_onFetchProspectStatuses);
  }

  Future<void> _onFetchProspectStatuses(
    FetchProspectStatusesEvent event,
    Emitter<ProspectStatusState> emit,
  ) async {
    emit(state.copyWith(status: ProspectStatusEnum.loading));

    final result = await getProspectStatusesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProspectStatusEnum.error,
        errorMessage: failure,
      )),
      (statuses) => emit(state.copyWith(
        status: ProspectStatusEnum.loaded,
        statuses: statuses,
      )),
    );
  }
}
