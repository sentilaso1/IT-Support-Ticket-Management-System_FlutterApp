import 'package:flutter/foundation.dart';

import '../../application/services/i_auth_service.dart';
import '../../domain/entities/user.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authService);

  final IAuthService _authService;

  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;
  User? _currentUser;
  int _operationId = 0;
  String? _activeLogin;

  LoginStatus get status => _status;

  bool get isLoading => _status == LoginStatus.loading;

  String? get errorMessage => _errorMessage;

  User? get currentUser => _currentUser;

  Future<void> restoreSession() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _status = _currentUser == null
          ? LoginStatus.initial
          : LoginStatus.success;
      _errorMessage = null;
    } catch (_) {
      _currentUser = null;
      _status = LoginStatus.initial;
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final normalizedLogin = username.trim().toLowerCase();
    if (isLoading && _activeLogin == normalizedLogin) {
      return false;
    }

    final operationId = ++_operationId;
    _activeLogin = normalizedLogin;
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        username: username,
        password: password,
      );
      if (operationId != _operationId) {
        return false;
      }
      _currentUser = user;
      _status = LoginStatus.success;
      _activeLogin = null;
      notifyListeners();
      return true;
    } catch (error) {
      if (operationId != _operationId) {
        return false;
      }
      _currentUser = null;
      _status = LoginStatus.failure;
      _errorMessage = error.toString();
      _activeLogin = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final operationId = ++_operationId;
    _activeLogin = null;
    await _authService.logout();
    if (operationId != _operationId) {
      return;
    }
    _currentUser = null;
    _status = LoginStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _status = LoginStatus.failure;
      _errorMessage = 'No signed-in user was found.';
      notifyListeners();
      return false;
    }

    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        user: user,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _currentUser = await _authService.getCurrentUser();
      _status = LoginStatus.success;
      notifyListeners();
      return true;
    } catch (error) {
      _status = LoginStatus.failure;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
