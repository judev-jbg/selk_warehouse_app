import 'package:equatable/equatable.dart';

abstract class LabelsEvent extends Equatable {
  const LabelsEvent();

  @override
  List<Object> get props => [];
}

class GetLabelsEvent extends LabelsEvent {}

class ToggleLabelSelectionEvent extends LabelsEvent {
  final String labelId;
  final bool selected;

  const ToggleLabelSelectionEvent({
    required this.labelId,
    required this.selected,
  });

  @override
  List<Object> get props => [labelId, selected];
}

class PrintLabelsEvent extends LabelsEvent {
  final List<String> labelIds;

  const PrintLabelsEvent({required this.labelIds});

  @override
  List<Object> get props => [labelIds];
}

class DeleteLabelEvent extends LabelsEvent {
  final String labelId;

  const DeleteLabelEvent({required this.labelId});

  @override
  List<Object> get props => [labelId];
}
