import '../../domain/entities/managed_user.dart';
import '../dtos/user_dto.dart';

class UserManagementMapper {
  const UserManagementMapper();

  ManagedUser mapToEntity(UserDto dto) {
    return ManagedUser(
      id: dto.id,
      fullName: dto.fullName,
      username: dto.username,
      email: dto.email,
      role: dto.role,
      departmentId: dto.departmentId,
      phoneNumber: dto.phoneNumber,
      avatarUrl: dto.avatarUrl,
      isActive: dto.isActive,
      mustChangePassword: dto.mustChangePassword,
      lastLoginAt: dto.lastLoginAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
