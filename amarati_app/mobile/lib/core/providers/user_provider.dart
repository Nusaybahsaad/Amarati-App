import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String get userName => _user?.name ?? '';
  String get userRole => _user?.role ?? 'tenant';

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
      );
      _user = user;
      notifyListeners();
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(phone: phone, password: password);
      _user = user;
      notifyListeners();
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRole(String role) async {
    if (_user == null) return;
    final updated = await _authService.updateRole(role, _user!.token);
    _user = updated.copyWith(token: _user!.token);
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _authService.getSavedToken();
    if (token == null) return false;

    final user = await _authService.getMe(token);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
