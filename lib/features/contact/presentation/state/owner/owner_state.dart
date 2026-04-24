import 'package:equatable/equatable.dart';
import '../../../domain/entities/owner.dart';

enum OwnerStatus { initial, loading, loaded, error }

class OwnerState extends Equatable {
  final OwnerStatus status;
  final List<Owner> owners;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String search;

  const OwnerState({
    this.status = OwnerStatus.initial,
    this.owners = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.search = '',
  });

  OwnerState copyWith({
    OwnerStatus? status,
    List<Owner>? owners,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? search,
  }) {
    return OwnerState(
      status: status ?? this.status,
      owners: owners ?? this.owners,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        owners,
        errorMessage,
        currentPage,
        hasReachedMax,
        search,
      ];
}
