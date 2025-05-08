import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/label.dart';
import '../../../domain/entities/product.dart';
import 'labels_event.dart';
import 'labels_state.dart';

class LabelsBloc extends Bloc<LabelsEvent, LabelsState> {
  // Temporalmente utiliza funciones vacías hasta que implementemos los casos de uso reales
  final dynamic getLabels;
  final dynamic printLabels;
  final dynamic deleteLabel;

  LabelsBloc({
    required this.getLabels,
    required this.printLabels,
    required this.deleteLabel,
  }) : super(LabelsInitial()) {
    on<GetLabelsEvent>(_onGetLabels);
    on<PrintLabelsEvent>(_onPrintLabels);
    on<DeleteLabelEvent>(_onDeleteLabel);
    on<ToggleLabelSelectionEvent>(_onToggleLabelSelection);
  }

  Future<void> _onGetLabels(
    GetLabelsEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    // Implementación temporal hasta que tengamos el repositorio real
    await Future.delayed(Duration(seconds: 1));

    // Para pruebas, creamos etiquetas ficticias
    final mockProduct = Product(
      id: '1',
      reference: 'REF-001',
      description: 'Producto de prueba',
      barcode: '1234567890123',
      location: 'A-01-02',
      stock: 100.0,
      unit: 'UND',
      status: 'Activo',
    );

    final mockLabels = [
      Label(
        id: '1',
        product: mockProduct,
        createdAt: DateTime.now().toString(),
      ),
      Label(
        id: '2',
        product: mockProduct,
        createdAt: DateTime.now().subtract(Duration(hours: 1)).toString(),
      ),
    ];

    if (mockLabels.isEmpty) {
      emit(LabelsEmpty());
    } else {
      emit(LabelsLoaded(mockLabels));
    }
  }

  Future<void> _onPrintLabels(
    PrintLabelsEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una impresión exitosa
    emit(LabelsPrintSuccess());

    // Recargamos las etiquetas actualizadas
    add(GetLabelsEvent());
  }

  Future<void> _onDeleteLabel(
    DeleteLabelEvent event,
    Emitter<LabelsState> emit,
  ) async {
    emit(LabelsLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos una eliminación exitosa
    emit(LabelDeleteSuccess());

    // Recargamos las etiquetas actualizadas
    add(GetLabelsEvent());
  }

  Future<void> _onToggleLabelSelection(
    ToggleLabelSelectionEvent event,
    Emitter<LabelsState> emit,
  ) async {
    // Obtenemos el estado actual
    if (state is LabelsLoaded) {
      final currentLabels = (state as LabelsLoaded).labels;

      // Actualizamos la selección de la etiqueta
      final updatedLabels =
          currentLabels.map((label) {
            if (label.id == event.labelId) {
              return label.copyWith(selected: event.selected);
            }
            return label;
          }).toList();

      emit(LabelsLoaded(updatedLabels));
    }
  }
}
