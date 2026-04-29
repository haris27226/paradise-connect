import 'package:equatable/equatable.dart';

abstract class ContactPropertiesEvent extends Equatable {
  const ContactPropertiesEvent();
  @override
  List<Object?> get props => [];
}

class FetchContactPropertiesEvent extends ContactPropertiesEvent {}
