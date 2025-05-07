import 'package:equatable/equatable.dart';
import 'product.dart';

class Label extends Equatable {
  final String id;
  final Product product;
  final String createdAt;
  final bool selected;

  const Label({
    required this.id,
    required this.product,
    required this.createdAt,
    this.selected = false,
  });

  Label copyWith({
    String? id,
    Product? product,
    String? createdAt,
    bool? selected,
  }) {
    return Label(
      id: id ?? this.id,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [id, product, createdAt, selected];
}
