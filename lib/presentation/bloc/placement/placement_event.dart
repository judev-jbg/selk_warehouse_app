import 'package:equatable/equatable.dart';

abstract class PlacementEvent extends Equatable {
  const PlacementEvent();

  @override
  List<Object?> get props => [];
}

class SearchProductEvent extends PlacementEvent {
  final String barcode;

  const SearchProductEvent({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class UpdateLocationEvent extends PlacementEvent {
  final String productId;
  final String newLocation;

  const UpdateLocationEvent({
    required this.productId,
    required this.newLocation,
  });

  @override
  List<Object?> get props => [productId, newLocation];
}

class UpdateStockEvent extends PlacementEvent {
  final String productId;
  final double newStock;

  const UpdateStockEvent({required this.productId, required this.newStock});

  @override
  List<Object?> get props => [productId, newStock];
}
