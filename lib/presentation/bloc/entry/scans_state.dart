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

class ScansError extends ScansState {
  final String message;

  const ScansError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanUpdateSuccess extends ScansState {
  final Scan scan;

  const ScanUpdateSuccess(this.scan);

  @override
  List<Object?> get props => [scan];
}

class ScanDeleteSuccess extends ScansState {}
