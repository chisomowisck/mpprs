import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1A3C5E);
  static const Color primaryVariant = Color(0xFF0D2741);
  static const Color primaryLight = Color(0xFF2D5F8A);
  static const Color secondary = Color(0xFFE8A020);
  static const Color secondaryLight = Color(0xFFFFF3E0);

  // Surfaces
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F2F7);
  static const Color divider = Color(0xFFE0E4EC);
  static const Color border = Color(0xFFCDD2DE);

  // Text
  static const Color textPrimary = Color(0xFF1A2535);
  static const Color textSecondary = Color(0xFF5A6478);
  static const Color textTertiary = Color(0xFF9BA5B5);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color paid = Color(0xFF2E7D32);
  static const Color paidLight = Color(0xFFE8F5E9);
  static const Color unpaid = Color(0xFF1565C0);
  static const Color unpaidLight = Color(0xFFE3F2FD);
  static const Color overdue = Color(0xFFC62828);
  static const Color overdueLight = Color(0xFFFFEBEE);
  static const Color pending = Color(0xFFE65100);
  static const Color pendingLight = Color(0xFFFFF3E0);
  static const Color voided = Color(0xFF616161);
  static const Color voidedLight = Color(0xFFF5F5F5);
  static const Color draft = Color(0xFF757575);
  static const Color draftLight = Color(0xFFFAFAFA);

  // Semantic
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color info = Color(0xFF1565C0);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

