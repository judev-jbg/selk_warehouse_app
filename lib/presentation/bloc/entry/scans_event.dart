import 'package:equatable/equatable.dart';

abstract class ScansEvent extends Equatable {
  const ScansEvent();

  @override
  List<Object?> get props => [];
}

class GetScansEvent extends ScansEvent {}

class UpdateScanEvent extends ScansEvent {
  final String scanId;
  final double newQuantity;

  const UpdateScanEvent({required this.scanId, required this.newQuantity});

  @override
  List<Object?> get props => [scanId, newQuantity];
}

class DeleteScanEvent extends ScansEvent {
  final String scanId;

  const DeleteScanEvent({required this.scanId});

  @override
  List<Object?> get props => [scanId];
}
