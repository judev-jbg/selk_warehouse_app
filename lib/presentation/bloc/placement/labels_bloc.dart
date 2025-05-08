import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/label.dart';
import '../../../domain/usecases/placement/get_labels.dart';
import '../../../domain/usecases/placement/print_labels.dart';
import '../../../domain/usecases/placement/delete_label.dart';
import 'labels_event.dart';
import 'labels_state.dart';

class LabelsBloc extends Bloc<LabelsEvent, LabelsState> {
  final GetLabels getLabels;
  final PrintLabels printLabels;
  final DeleteLabel deleteLabel;

  // Mantener estado local de etiquetas
  List<Label> _labels = [];

  LabelsBloc({
    required this.getLabels,
    required this.printLabels,
    required this.deleteLabel,
  }) : super(LabelsInitial()) {
    on<GetLabelsEvent>(_onGetLabels);
    on<ToggleLabelSelectionEvent>(_onToggleLabelSelection);
    on<PrintLabelsEvent>(_onPrintLabels);
    on<DeleteLabelEvent>(_onDeleteLabel);
  }

  Future<void> _onGetLabels(
    GetLabelsEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    final result = await getLabels(NoParams());

    result.fold((failure) => emit(LabelsError(failure.message)), (labels) {
      _labels = labels;
      if (labels.isEmpty) {
        emit(LabelsEmpty());
      } else {
        emit(LabelsLoaded(labels));
      }
    });
  }

  void _onToggleLabelSelection(
    ToggleLabelSelectionEvent event,
    Emitter<LabelsState> emit,
  ) {
    final updatedLabels =
        _labels.map((label) {
          if (label.id == event.labelId) {
            return label.copyWith(selected: event.selected);
          }
          return label;
        }).toList();

    _labels = updatedLabels;
    emit(LabelsLoaded(updatedLabels));
  }

  Future<void> _onPrintLabels(
    PrintLabelsEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    final result = await printLabels(
      PrintLabelsParams(labelIds: event.labelIds),
    );

    result.fold((failure) => emit(LabelsError(failure.message)), (
      printedLabels,
    ) {
      // Actualizar etiquetas locales
      final updatedLabels =
          _labels.map((label) {
            if (event.labelIds.contains(label.id)) {
              return label.copyWith(printed: true, selected: false);
            }
            return label;
          }).toList();

      _labels = updatedLabels;
      emit(LabelsPrintSuccess(printedLabels));
      emit(LabelsLoaded(updatedLabels));
    });
  }

  Future<void> _onDeleteLabel(
    DeleteLabelEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    final result = await deleteLabel(DeleteLabelParams(labelId: event.labelId));

    result.fold((failure) => emit(LabelsError(failure.message)), (_) {
      // Eliminar etiqueta de la lista local
      _labels.removeWhere((label) => label.id == event.labelId);

      emit(LabelDeleteSuccess(event.labelId));

      if (_labels.isEmpty) {
        emit(LabelsEmpty());
      } else {
        emit(LabelsLoaded(_labels));
      }
    });
  }
}
