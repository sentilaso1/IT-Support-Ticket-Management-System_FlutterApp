import 'package:flutter/foundation.dart';

import '../../application/services/i_user_management_service.dart';

class UpdateUserViewModel extends ChangeNotifier {
  UpdateUserViewModel(this._service);

  final IUserManagementService _service;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
    int? departmentId,
    String? phoneNumber,
    required bool isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateUser(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
        departmentId: departmentId,
        phoneNumber: phoneNumber,
        isActive: isActive,
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
