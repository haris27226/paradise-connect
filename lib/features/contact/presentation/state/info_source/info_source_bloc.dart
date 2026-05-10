import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/contact/domain/usecases/info_source/get_info_sources_usecase.dart';
import 'info_source_event.dart';
import 'info_source_state.dart';

class InfoSourceBloc extends Bloc<InfoSourceEvent, InfoSourceState> {
  final GetInfoSourcesUseCase getInfoSourcesUseCase;

  InfoSourceBloc({required this.getInfoSourcesUseCase}) : super(const InfoSourceState()) {
    on<FetchInfoSourcesEvent>(_onFetchInfoSources);
  }

  Future<void> _onFetchInfoSources(
    FetchInfoSourcesEvent event,
    Emitter<InfoSourceState> emit,
  ) async {
    emit(state.copyWith(status: InfoSourceStatus.loading));

    final result = await getInfoSourcesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: InfoSourceStatus.error,
        errorMessage: failure,
      )),
      (sources) => emit(state.copyWith(
        status: InfoSourceStatus.loaded,
        sources: sources,
      )),
    );
  }
}