import 'package:equatable/equatable.dart';

abstract class DeliveryNoteEvent extends Equatable {
  const DeliveryNoteEvent();

  @override
  List<Object?> get props => [];
}

class GetSuppliersEvent extends DeliveryNoteEvent {}

class SelectSupplierEvent extends DeliveryNoteEvent {
  final String supplierId;

  const SelectSupplierEvent({required this.supplierId});

  @override
  List<Object?> get props => [supplierId];
}

class GenerateDeliveryNoteEvent extends DeliveryNoteEvent {
  final String supplierReference;

  const GenerateDeliveryNoteEvent({required this.supplierReference});

  @override
  List<Object?> get props => [supplierReference];
}
