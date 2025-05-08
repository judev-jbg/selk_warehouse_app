import 'package:equatable/equatable.dart';
import '../../../domain/entities/supplier.dart';
import '../../../domain/entities/delivery_note.dart';
import '../../../domain/entities/scan.dart';

abstract class DeliveryNoteState extends Equatable {
  const DeliveryNoteState();

  @override
  List<Object?> get props => [];
}

class DeliveryNoteInitial extends DeliveryNoteState {}

class DeliveryNoteLoading extends DeliveryNoteState {}

class SuppliersLoaded extends DeliveryNoteState {
  final List<Supplier> suppliers;

  const SuppliersLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class ScansForDeliveryNoteLoaded extends DeliveryNoteState {
  final List<Scan> scans;

  const ScansForDeliveryNoteLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}

class DeliveryNoteGenerated extends DeliveryNoteState {
  final DeliveryNote deliveryNote;

  const DeliveryNoteGenerated(this.deliveryNote);

  @override
  List<Object?> get props => [deliveryNote];
}

class DeliveryNoteError extends DeliveryNoteState {
  final String message;

  const DeliveryNoteError(this.message);

  @override
  List<Object?> get props => [message];
}
