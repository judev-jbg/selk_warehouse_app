import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class BarcodeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final bool enabled;

  const BarcodeSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.onClear,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primary : AppColors.divider,
          width: focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        inputFormatters: [
          // Permitir solo números y algunos caracteres especiales del escáner
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\n\t\r]')),
        ],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Escanear o ingresar código de barras...',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.qr_code_scanner,
            color: focusNode.hasFocus ? AppColors.primary : AppColors.textHint,
            size: 24,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textHint),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSearch(controller.text.trim());
                    }
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            onSearch(value.trim());
          }
        },
        onTap: () {
          // Asegurar que el foco esté en el campo
          if (!focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        },
      ),
    );
  }
}
