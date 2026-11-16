
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../services/api_client.dart';

/// Manages authentication state using the Spring Boot backend.
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() => _instance;

  AuthRepository._internal();

  UserModel? _currentUser;
  String? _token;
  int? _expiresAt;

  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null && _token != null;

  String? get token => _token;

  int? get expiresAt => _expiresAt;

  /// Authenticates a user using the backend login endpoint.
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      final token = data['token'] as String;
      final authenticatedEmail = data['email'] as String;
      final expiresAt = data['expiresAt'] as int?;

      _token = token;
      _expiresAt = expiresAt;
      ApiClient.accessToken = token;

      final name = authenticatedEmail.split('@').first;
      final initials = name.isNotEmpty
          ? name.substring(0, 1).toUpperCase()
          : 'U';

      _currentUser = UserModel(
        id: authenticatedEmail,
        name: name,
        email: authenticatedEmail,
        role: 'Fleet Operator',
        avatarInitials: initials,
      );

      notifyListeners();
      return true;
    } on DioException {
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Logs out the user and clears authentication state.
  void logout() {
    _currentUser = null;
    _token = null;
    _expiresAt = null;
    ApiClient.accessToken = null;

    notifyListeners();
  }
}