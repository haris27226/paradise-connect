import 'package:equatable/equatable.dart';
import '../../../domain/entities/contact_property.dart';

enum ContactPropertiesStatus { initial, loading, loaded, error }

class ContactPropertiesState extends Equatable {
  final ContactPropertiesStatus status;
  final List<ContactPropertyGroup> groups;
  final String? errorMessage;

  const ContactPropertiesState({
    this.status = ContactPropertiesStatus.initial,
    this.groups = const [],
    this.errorMessage,
  });

  ContactPropertiesState copyWith({
    ContactPropertiesStatus? status,
    List<ContactPropertyGroup>? groups,
    String? errorMessage,
  }) {
    return ContactPropertiesState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, groups, errorMessage];
}
