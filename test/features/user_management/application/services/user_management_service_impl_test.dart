import 'package:flutter_test/flutter_test.dart';
import 'package:it_ticket_support_management/core/errors/exceptions.dart';
import 'package:it_ticket_support_management/features/user_management/application/services/user_management_service_impl.dart';
import 'package:it_ticket_support_management/features/user_management/domain/entities/managed_user.dart';
import 'package:it_ticket_support_management/features/user_management/domain/repositories/i_user_management_repository.dart';

void main() {
  group('administrator account protection', () {
    test('user management list excludes administrator accounts', () async {
      final repository = _UserRepositoryFake(
        users: [
          _user(id: 1, role: 'admin'),
          _user(id: 2, role: 'staff'),
        ],
      );
      final service = UserManagementServiceImpl(repository);

      final users = await service.getUsers();

      expect(users.map((user) => user.id), [2]);
      expect(users.any((user) => user.role == 'admin'), isFalse);
    });

    test('administrator account cannot be disabled through service', () async {
      final repository = _UserRepositoryFake(
        users: [_user(id: 1, role: 'admin')],
      );
      final service = UserManagementServiceImpl(repository);

      await expectLater(
        service.setUserActive(id: 1, isActive: false),
        throwsA(isA<AppException>()),
      );
      expect(repository.setActiveCalls, 0);
    });

    test('regular account can still be disabled', () async {
      final repository = _UserRepositoryFake(
        users: [_user(id: 2, role: 'staff')],
      );
      final service = UserManagementServiceImpl(repository);

      await service.setUserActive(id: 2, isActive: false);

      expect(repository.setActiveCalls, 1);
      expect(repository.lastActiveValue, isFalse);
    });
  });
}

ManagedUser _user({required int id, required String role}) {
  return ManagedUser(
    id: id,
    fullName: 'User $id',
    username: 'user$id',
    email: 'user$id@example.com',
    role: role,
    isActive: true,
    mustChangePassword: false,
    createdAt: DateTime(2026),
  );
}

class _UserRepositoryFake implements IUserManagementRepository {
  _UserRepositoryFake({required this.users});

  final List<ManagedUser> users;
  int setActiveCalls = 0;
  bool? lastActiveValue;

  @override
  Future<List<ManagedUser>> getUsers() async => users;

  @override
  Future<ManagedUser?> getUserById(int id) async {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  @override
  Future<void> setUserActive({required int id, required bool isActive}) async {
    setActiveCalls++;
    lastActiveValue = isActive;
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
  }) async {}

  @override
  Future<void> updateUser({
    required int id,
    required String fullName,
    required String email,
    required String role,
    int? departmentId,
    String? phoneNumber,
    required bool isActive,
  }) async {}

  @override
  Future<void> resetTemporaryPassword({
    required int id,
    required String temporaryPassword,
  }) async {}
}
