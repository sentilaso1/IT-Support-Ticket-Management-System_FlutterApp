import 'package:flutter/foundation.dart';

import '../../application/services/i_user_management_service.dart';

class CreateUserViewModel extends ChangeNotifier {
  CreateUserViewModel(this._service);

  final IUserManagementService _service;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> createUser({
    required String fullName,
    required String username,
    required String email,
    required String temporaryPassword,
    required String role,
    int? departmentId,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createUser(
        fullName: fullName,
        username: username,
        email: email,
        temporaryPassword: temporaryPassword,
        role: role,
        departmentId: departmentId,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
