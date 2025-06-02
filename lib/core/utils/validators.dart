// lib/core/utils/validators.dart
import 'package:selk_warehouse_app/shared/utils/extensions.dart';

class Validators {
  // Validador de username
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El usuario es requerido';
    }

    if (value.trim().length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }

    if (value.trim().length > 50) {
      return 'El usuario no puede tener más de 50 caracteres';
    }

    // Opcional: validar caracteres permitidos
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value.trim())) {
      return 'El usuario solo puede contener letras, números, puntos, guiones y guiones bajos';
    }

    return null;
  }

  // Validador de contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 1) {
      return 'La contraseña debe tener al menos 1 caracter';
    }

    return null;
  }

  // Validador de email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }

    if (!value.trim().isValidEmail) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  // Validador requerido genérico
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  // Validador de longitud mínima
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  // Validador de longitud máxima
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }
    return null;
  }
}
