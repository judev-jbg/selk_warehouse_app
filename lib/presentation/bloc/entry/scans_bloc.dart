import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/entry/get_scans.dart';
import '../../../domain/usecases/entry/update_scan.dart';
import '../../../domain/usecases/entry/delete_scan.dart';
import '../../../domain/usecases/usecase.dart';
import 'scans_event.dart';
import 'scans_state.dart';

class ScansBloc extends Bloc<ScansEvent, ScansState> {
  final GetScans getScans;
  final UpdateScan updateScan;
  final DeleteScan deleteScan;

  ScansBloc({
    required this.getScans,
    required this.updateScan,
    required this.deleteScan,
  }) : super(ScansInitial()) {
    on<GetScansEvent>(_onGetScans);
    on<UpdateScanEvent>(_onUpdateScan);
    on<DeleteScanEvent>(_onDeleteScan);
  }

  Future<void> _onGetScans(
    GetScansEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    final result = await getScans(NoParams());

    result.fold((failure) => emit(ScansError(failure.message)), (scans) {
      if (scans.isEmpty) {
        emit(ScansEmpty());
      } else {
        emit(ScansLoaded(scans));
      }
    });
  }

  Future<void> _onUpdateScan(
    UpdateScanEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    final result = await updateScan(
      UpdateScanParams(scanId: event.scanId, newQuantity: event.newQuantity),
    );

    result.fold((failure) => emit(ScansError(failure.message)), (updatedScan) {
      emit(ScanUpdateSuccess(updatedScan));
      add(GetScansEvent()); // Recargar la lista de lecturas
    });
  }

  Future<void> _onDeleteScan(
    DeleteScanEvent event,
    Emitter<ScansState> emit,
  ) async {
    emit(ScansLoading());

    final result = await deleteScan(DeleteScanParams(scanId: event.scanId));

    result.fold((failure) => emit(ScansError(failure.message)), (_) {
      emit(ScanDeleteSuccess(event.scanId));
      add(GetScansEvent()); // Recargar la lista de lecturas
    });
  }
}
