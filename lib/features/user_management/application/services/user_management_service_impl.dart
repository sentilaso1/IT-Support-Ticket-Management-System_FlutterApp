import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/repositories/i_user_management_repository.dart';
import 'i_user_management_service.dart';

class UserManagementServiceImpl implements IUserManagementService {
  const UserManagementServiceImpl(this._repository);

  final IUserManagementRepository _repository;

  @override
  Future<List<ManagedUser>> getUsers() {
    return _repository.getUsers();
  }

  @override
  Future<void> createUser({
    required String fullName,
    required String username,
    required String email,
    required String temporaryPassword,
    required String role,
    int? departmentId,
    String? phoneNumber,
  }) {
    _validateUserInput(
      fullName: fullName,
      username: username,
      email: email,
      role: role,
      departmentId: departmentId,
      requireUsername: true,
    );

    if (temporaryPassword.length < 8) {
      throw const AppException(
        'Temporary password must have at least 8 characters.',
      );
    }

    return _repository.createUser(
      fullName: fullName.trim(),
      username: username.trim(),
      email: email.trim(),
      temporaryPassword: temporaryPassword,
      role: role,
      departmentId: departmentId,
      phoneNumber: _emptyToNull(phoneNumber),
    );
  }

  @override
  Future<void> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
    int? departmentId,
    String? phoneNumber,
    required bool isActive,
  }) {
    _validateUserInput(
      fullName: fullName,
      username: 'not-updated',
      email: email,
      role: role,
      departmentId: departmentId,
      requireUsername: false,
    );

    return _repository.updateUser(
      id: id,
      fullName: fullName.trim(),
      email: email.trim(),
      role: role,
      departmentId: departmentId,
      phoneNumber: _emptyToNull(phoneNumber),
      isActive: isActive,
    );
  }

  @override
  Future<void> setUserActive({
    required int id,
    required bool isActive,
  }) {
    return _repository.setUserActive(id: id, isActive: isActive);
  }

  @override
  Future<void> resetTemporaryPassword({
    required int id,
    required String temporaryPassword,
  }) {
    if (temporaryPassword.length < 8) {
      throw const AppException(
        'Temporary password must have at least 8 characters.',
      );
    }

    return _repository.resetTemporaryPassword(
      id: id,
      temporaryPassword: temporaryPassword,
    );
  }

  void _validateUserInput({
    required String fullName,
    required String username,
    required String email,
    required String role,
    required int? departmentId,
    required bool requireUsername,
  }) {
    if (fullName.trim().isEmpty) {
      throw const AppException('Full name is required.');
    }

    if (requireUsername && username.trim().isEmpty) {
      throw const AppException('Username is required.');
    }

    if (!email.contains('@')) {
      throw const AppException('A valid email is required.');
    }

    final parsedRole = UserRole.fromValue(role);
    if (parsedRole == UserRole.staff && departmentId == null) {
      throw const AppException('Staff account must belong to a department.');
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
