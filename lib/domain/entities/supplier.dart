import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String? code;
  final String? contactPerson;
  final String? phone;
  final String? email;

  const Supplier({
    required this.id,
    required this.name,
    this.code,
    this.contactPerson,
    this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, code, contactPerson, phone, email];
}
