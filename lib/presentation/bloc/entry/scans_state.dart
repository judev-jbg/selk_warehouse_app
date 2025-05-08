import 'package:equatable/equatable.dart';
import '../../../domain/entities/scan.dart';

abstract class ScansState extends Equatable {
  const ScansState();

  @override
  List<Object?> get props => [];
}

class ScansInitial extends ScansState {}

class ScansLoading extends ScansState {}

class ScansLoaded extends ScansState {
  final List<Scan> scans;

  const ScansLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}

class ScansEmpty extends ScansState {}

class ScanUpdateSuccess extends ScansState {
  final Scan updatedScan;

  const ScanUpdateSuccess(this.updatedScan);

  @override
  List<Object?> get props => [updatedScan];
}

class ScanDeleteSuccess extends ScansState {
  final String scanId;

  const ScanDeleteSuccess(this.scanId);

  @override
  List<Object?> get props => [scanId];
}

class ScansError extends ScansState {
  final String message;

  const ScansError(this.message);

  @override
  List<Object?> get props => [message];
}
