import 'package:flutter/material.dart';

/// Centralized application color palette and design tokens.
/// Adheres to corporate enterprise design: Deep blue & corporate blue as primary brand colors,
/// clean light backgrounds, green for active/success states, and red exclusively for errors and destructive actions.
class AppColors {
  // Corporate Brand Colors (Corporate Blue & Deep Navy)
  static const Color primary = Color(0xFF1D4ED8); // Corporate Blue
  static const Color primaryHover = Color(0xFF1E40AF); // Darker corporate blue
  static const Color primaryLight = Color(0xFFEFF6FF); // Soft blue background tint
  static const Color primaryContainer = Color(0xFFDBEAFE); // Blue container highlight
  static const Color secondary = Color(0xFF334155); // Slate slate-grey

  // Deep Blue / Corporate Neutrals
  static const Color deepBlue = Color(0xFF0F172A); // Deep corporate navy
  static const Color starkDark = Color(0xFF0F172A); // Backward-compatible alias
  static const Color starkNavy = Color(0xFF1E293B);
  static const Color starkSteel = Color(0xFF475569);

  // Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean enterprise light canvas
  static const Color surfaceLight = Color(0xFFFFFFFF); // Card & panel surface

  // Sidebar Styling (Desktop left-navigation)
  static const Color sidebarLight = Color(0xFF0F172A); // Deep navy sidebar
  static const Color sidebarSelected = Color(0xFF1E293B); // Active navigation selection
  static const Color sidebarBg = Color(0xFF0F172A);
  static const Color sidebarActive = Color(0xFF1E293B);
  static const Color sidebarText = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Borders & Dividers (Subtle, crisp borders)
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle 1px border
  static const Color borderMedium = Color(0xFFCBD5E1); // Defined control border
  static const Color borderDark = Color(0xFF334155);

  // Typography Tones
  static const Color textPrimary = Color(0xFF0F172A); // Primary high-contrast text
  static const Color textSecondary = Color(0xFF475569); // Muted body & descriptions
  static const Color textMuted = Color(0xFF94A3B8); // Placeholders & metadata

  // Semantic Status Colors
  // Green exclusively for active/success states
  static const Color statusActive = Color(0xFF16A34A);
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusActiveBorder = Color(0xFF86EFAC);

  // Sky blue for available
  static const Color statusAvailable = Color(0xFF0284C7);
  static const Color statusAvailableBg = Color(0xFFE0F2FE);

  // Amber for in-maintenance/warning
  static const Color statusMaintenance = Color(0xFFD97706);
  static const Color statusMaintenanceBg = Color(0xFFFEF3C7);
  static const Color statusMaintenanceBorder = Color(0xFFFDE68A);

  // Red exclusively for errors and destructive actions (delete)
  static const Color statusOutOfService = Color(0xFFDC2626);
  static const Color statusOutOfServiceBg = Color(0xFFFEE2E2);
  static const Color statusOutOfServiceBorder = Color(0xFFFECACA);

  // Slate/Neutral for reserved
  static const Color statusReserved = Color(0xFF64748B);
  static const Color statusReservedBg = Color(0xFFF1F5F9);
  static const Color statusReservedBorder = Color(0xFFCBD5E1);
}
