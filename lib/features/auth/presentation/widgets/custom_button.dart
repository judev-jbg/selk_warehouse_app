// lib/features/auth/presentation/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.width,
    this.height = 50,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.textOnPrimary,
          elevation: type == ButtonType.primary ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: type == ButtonType.outline
                ? BorderSide(
                    color: isButtonEnabled
                        ? AppColors.primary
                        : AppColors.disabled,
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getForegroundColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.textOnPrimary;
      case ButtonType.secondary:
        return AppColors.textOnPrimary;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}
