import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/order_line.dart';
import '../../../domain/entities/customer_delivery_note.dart';
import '../../widgets/common/loading_overlay.dart';

class LoadOrderSummaryPage extends StatelessWidget {
  final String loadOrderId;

  const LoadOrderSummaryPage({Key? key, required this.loadOrderId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
