import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

/// Manages authentication state for the admin portal.
/// Mock implementation to simulate logging in/out without real backend token calls.
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Simulates login with email & password.
  /// Accepts any valid email/password for mock demo, or specifically admin@vms.corp.
  Future<bool> login(String email, String password) async {
    // Artificial small delay to simulate network roundtrip in UI
    await Future.delayed(const Duration(milliseconds: 300));

    if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
      _currentUser = UserModel(
        id: 'usr-001',
        name: email.contains('admin') ? 'Alex Johnson (Admin)' : 'Fleet Operator',
        email: email,
        role: email.contains('admin') ? 'Fleet Manager' : 'Operations Specialist',
        avatarInitials: email.contains('admin') ? 'AJ' : 'FO',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logs out the user and clears state.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
