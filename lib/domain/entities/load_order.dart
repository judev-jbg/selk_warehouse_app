import 'package:equatable/equatable.dart';

enum LoadOrderStatus { pending, inProgress, incomplete, completed }

class LoadOrder extends Equatable {
  final String id;
  final String number;
  final String createdAt;
  final LoadOrderStatus status;
  final int totalProducts;
  final int completedProducts;

  const LoadOrder({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.totalProducts,
    required this.completedProducts,
  });

  @override
  List<Object?> get props => [
    id,
    number,
    createdAt,
    status,
    totalProducts,
    completedProducts,
  ];
}
