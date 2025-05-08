import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required String id,
    required String name,
    String? code,
    String? contactPerson,
    String? phone,
    String? email,
  }) : super(
         id: id,
         name: name,
         code: code,
         contactPerson: contactPerson,
         phone: phone,
         email: email,
       );

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
    };
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      code: supplier.code,
      contactPerson: supplier.contactPerson,
      phone: supplier.phone,
      email: supplier.email,
    );
  }
}
