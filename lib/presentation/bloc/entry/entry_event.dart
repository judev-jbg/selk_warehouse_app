import 'package:equatable/equatable.dart';

abstract class EntryEvent extends Equatable {
  const EntryEvent();

  @override
  List<Object?> get props => [];
}

class ScanProductEvent extends EntryEvent {
  final String barcode;

  const ScanProductEvent({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class ResetScanEvent extends EntryEvent {}
