import 'package:equatable/equatable.dart';
import '../../../domain/entities/label.dart';

abstract class LabelsState extends Equatable {
  const LabelsState();

  @override
  List<Object?> get props => [];
}

class LabelsInitial extends LabelsState {}

class LabelsLoading extends LabelsState {}

class LabelsLoaded extends LabelsState {
  final List<Label> labels;

  const LabelsLoaded(this.labels);

  @override
  List<Object?> get props => [labels];
}

class LabelsEmpty extends LabelsState {}

class LabelsError extends LabelsState {
  final String message;

  const LabelsError(this.message);

  @override
  List<Object?> get props => [message];
}

class LabelsPrintSuccess extends LabelsState {}

class LabelDeleteSuccess extends LabelsState {}
