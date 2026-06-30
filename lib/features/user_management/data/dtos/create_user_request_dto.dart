class CreateUserRequestDto {
  const CreateUserRequestDto({
    required this.fullName,
    required this.username,
    required this.email,
    required this.temporaryPasswordHash,
    required this.role,
    this.departmentId,
    this.phoneNumber,
  });

  final String fullName;
  final String username;
  final String email;
  final String temporaryPasswordHash;
  final String role;
  final int? departmentId;
  final String? phoneNumber;

  Map<String, Object?> toMap(DateTime now) {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'passwordHash': temporaryPasswordHash,
      'role': role,
      'departmentId': departmentId,
      'phoneNumber': phoneNumber,
      'isActive': 1,
      'mustChangePassword': 1,
      'createdAt': now.toIso8601String(),
    };
  }
}
