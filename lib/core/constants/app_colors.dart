import 'package:flutter/material.dart';

/// Centralized application color palette and semantic colors.
/// Incorporates Stark Group industrial styling with enterprise Material 3 tones.
class AppColors {
  // Brand / Seed Colors
  static const Color primary = Color(0xFFEA580C); // Stark Industrial Safety Orange
  static const Color primaryHover = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFFEDD5);
  static const Color primaryContainer = Color(0xFFFFEDD5);
  static const Color secondary = Color(0xFF455A64);
  static const Color accent = Color(0xFF00897B);

  // Corporate Neutrals & Dark Tones
  static const Color starkDark = Color(0xFF0F172A);
  static const Color starkNavy = Color(0xFF1E293B);
  static const Color starkSteel = Color(0xFF334155);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Sidebar Styling (for desktop & tablet drawers)
  static const Color sidebarLight = Color(0xFF0F172A); // Modern dark sidebar
  static const Color sidebarSelected = Color(0xFF1E293B);
  static const Color sidebarBg = Color(0xFF0F172A);
  static const Color sidebarActive = Color(0xFF1E293B);
  static const Color sidebarText = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF334155);

  // Typography Tones
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic Status Colors
  static const Color statusActive = Color(0xFF16A34A); // Emerald green
  static const Color statusActiveBg = Color(0xFFDCFCE7);

  static const Color statusAvailable = Color(0xFF0284C7); // Sky blue
  static const Color statusAvailableBg = Color(0xFFE0F2FE);

  static const Color statusMaintenance = Color(0xFFD97706); // Amber
  static const Color statusMaintenanceBg = Color(0xFFFEF3C7);

  static const Color statusOutOfService = Color(0xFFDC2626); // Crimson red
  static const Color statusOutOfServiceBg = Color(0xFFFEE2E2);

  static const Color statusReserved = Color(0xFF8B5CF6); // Purple
  static const Color statusReservedBg = Color(0xFFEDE9FE);
}
