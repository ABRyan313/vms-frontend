import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/vehicles/vehicle_form_screen.dart';

/// Centralized route definitions and generator for the VMS frontend application.
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String vehicles = '/vehicles';
  static const String vehicleRegister = '/vehicles/register';
  static const String vehicleEdit = '/vehicles/edit';

  /// Generates the appropriate Route based on RouteSettings.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 0),
          settings: settings,
        );

      case vehicles:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 1),
          settings: settings,
        );

      case vehicleRegister:
        return MaterialPageRoute(
          builder: (_) => const VehicleFormScreen(),
          settings: settings,
        );

      case vehicleEdit:
        final vehicle = settings.arguments as Vehicle?;
        return MaterialPageRoute(
          builder: (_) => VehicleFormScreen(vehicleToEdit: vehicle),
          settings: settings,
        );

      default:
        // Default fallback route is Login
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
