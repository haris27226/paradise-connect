import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/attachment/get_attachment_types_usecase.dart';
import 'attachment_type_event.dart';
import 'attachment_type_state.dart';

class AttachmentTypeBloc extends Bloc<AttachmentTypeEvent, AttachmentTypeState> {
  final GetAttachmentTypesUseCase getAttachmentTypesUseCase;

  AttachmentTypeBloc(this.getAttachmentTypesUseCase) : super(AttachmentTypeInitial()) {
    on<FetchAttachmentTypesEvent>((event, emit) async {
      emit(AttachmentTypeLoading());
      final result = await getAttachmentTypesUseCase();
      result.fold(
        (failure) => emit(AttachmentTypeError(failure)),
        (data) => emit(AttachmentTypeLoaded(data)),
      );
    });
  }
}
