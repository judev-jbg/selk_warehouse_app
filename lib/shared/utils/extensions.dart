// lib/shared/utils/extensions.dart
import 'package:selk_warehouse_app/features/auth/domain/entities/user.dart';

extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isNotEmpty {
    return trim().isNotEmpty;
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isExpired {
    return isBefore(DateTime.now());
  }

  bool get shouldRefresh {
    // Refrescar si faltan menos de 5 minutos para expirar
    final threshold = DateTime.now().add(const Duration(minutes: 5));
    return isBefore(threshold);
  }

  String get timeAgo {
    final difference = DateTime.now().difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Ahora';
    }
  }
}

extension UserPermissionsExtension on User {
  bool canRead(String module) {
    return permissions.hasPermission(module, 'read');
  }

  bool canWrite(String module) {
    return permissions.hasPermission(module, 'write');
  }

  bool isAdmin(String module) {
    return permissions.hasPermission(module, 'admin');
  }

  List<String> get availableModules {
    final modules = <String>[];

    if (canRead('colocacion')) modules.add('colocacion');
    if (canRead('entrada')) modules.add('entrada');
    if (canRead('recogida')) modules.add('recogida');

    return modules;
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}
